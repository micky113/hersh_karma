const { onRequest } = require("firebase-functions/v2/https");
const { VertexAI } = require("@google-cloud/vertexai");
const cors = require("cors")({ origin: true });

// Initialize Vertex AI on GCP Project hersh-karma
const PROJECT_ID = process.env.GCLOUD_PROJECT || "hersh-karma";
const LOCATION = "us-central1";

const vertexAI = new VertexAI({
  project: PROJECT_ID,
  location: LOCATION,
});

exports.analyzeProofOfGood = onRequest(
  {
    cors: true,
    timeoutSeconds: 60,
    memory: "512MiB",
    maxInstances: 10,
  },
  (req, res) => {
    return cors(req, res, async () => {
      if (req.method === "OPTIONS") {
        return res.status(204).send("");
      }

      if (req.method !== "POST") {
        return res.status(405).json({ error: "Method Not Allowed. Use POST." });
      }

      try {
        const {
          beforeImage,
          afterImage,
          deedTitle = "Civic Action",
          category = "General",
          description = "",
          latitude,
          longitude,
        } = req.body || {};

        if (!beforeImage || !afterImage) {
          return res.status(400).json({
            error: "Missing beforeImage or afterImage base64 strings.",
          });
        }

        // Clean base64 strings if they contain data URL headers
        const cleanBefore = beforeImage.replace(/^data:image\/\w+;base64,/, "").trim();
        const cleanAfter = afterImage.replace(/^data:image\/\w+;base64,/, "").trim();

        const generativeModel = vertexAI.getGenerativeModel({
          model: "gemini-2.5-flash",
          generationConfig: {
            responseMimeType: "application/json",
            temperature: 0.1,
            maxOutputTokens: 1500,
          },
        });

        const prompt = `You are the Proof-of-Good AI Verification & Object Recognition Engine for the Karma Grid ecosystem.
Analyze these two photos:
- Photo 1 is the BEFORE photo.
- Photo 2 is the AFTER photo.

Deed Title: "${deedTitle}"
Category: "${category}"
Description: "${description || 'Community impact deed'}"
GPS Coordinates: ${latitude && longitude ? `${latitude}, ${longitude}` : 'Verified enclave'}

CRITICAL STRICT OBJECT RECOGNITION & VERIFICATION RULES:
1. Object Recognition: Explicitly list all identifiable physical objects, living beings, materials, and ground types in 'detectedObjectsBefore' and 'detectedObjectsAfter'.
2. Ground Truth Inspection: Carefully inspect what is ACTUALLY visible in the pixels of Photo 1 vs Photo 2.
3. Identical / Unchanged Photos: If Photo 1 and Photo 2 are identical, duplicate, or show NO visible positive transformation:
   - Set whatSeenBefore = "Exact description of Photo 1"
   - Set whatSeenAfter = "Exact description of Photo 2"
   - Set detectedObjectsBefore = [detected objects in Photo 1]
   - Set detectedObjectsAfter = [detected objects in Photo 2]
   - Set visualDifference = "0% difference - identical photos"
   - Set isGoodDeedDetected = false
   - Set evidenceScore = 20
   - Set isTampered = true
   - Set changeSummary = "Identical photos uploaded: No visible change or action detected."
   - Set reasoning = "Both photos show an unchanged scene with no evidence of the claimed action."
4. Irrelevant / Empty Scenes: If photos show an unrelated scene that does NOT contain the claimed activity (e.g. photos of only a plain floor, wall, or empty table when the deed claims animal welfare or tree planting):
   - Set whatSeenBefore = "Description of Photo 1 (e.g. bare floor with no animals)"
   - Set whatSeenAfter = "Description of Photo 2 (e.g. bare floor with no animals)"
   - Set detectedObjectsBefore = [e.g. "bare floor", "tile surface"]
   - Set detectedObjectsAfter = [e.g. "bare floor", "tile surface"]
   - Set visualDifference = "No relevant activity, animals, or objects detected"
   - Set isGoodDeedDetected = false
   - Set evidenceScore = 25
   - Set isTampered = true
   - Set changeSummary = "No ${category} transformation visible in photos."
   - Set reasoning = "Photos show an unrelated scene that does not match the claimed deed category."
5. Genuine Positive Transformation:
   - Set whatSeenBefore = "Description of baseline state in Photo 1"
   - Set whatSeenAfter = "Description of positive outcome state in Photo 2"
   - Set detectedObjectsBefore = [list all objects in Photo 1]
   - Set detectedObjectsAfter = [list all objects in Photo 2]
   - Set visualDifference = "Detailed description of what positive change occurred"
   - Set isGoodDeedDetected = true
   - Set evidenceScore = 90 to 100 for clear transformation in identical location.
   - Set isTampered = false
6. DO NOT assume, fabricate, or imagine positive actions or objects that are not visible in the image pixels.

Return ONLY a valid JSON object matching this schema:
{
  "whatSeenBefore": "Precise visual description of objects, living beings, and surroundings in Photo 1",
  "whatSeenAfter": "Precise visual description of objects, living beings, and surroundings in Photo 2",
  "detectedObjectsBefore": ["object 1", "object 2", "object 3"],
  "detectedObjectsAfter": ["object 1", "object 2", "object 3"],
  "visualDifference": "Exact visual changes observed between Photo 1 and Photo 2",
  "isGoodDeedDetected": true,
  "evidenceScore": 94,
  "sceneMatchConfidence": 0.95,
  "changeSummary": "Clear summary of transformation.",
  "measurableBefore": "Visible baseline state",
  "measurableAfter": "Restored outcome state",
  "isTampered": false,
  "reasoning": "Detailed visual analysis justifying the verdict."
}`;

        const reqPayload = {
          contents: [
            {
              role: "user",
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanBefore,
                  },
                },
                {
                  inlineData: {
                    mimeType: "image/jpeg",
                    data: cleanAfter,
                  },
                },
              ],
            },
          ],
        };

        const result = await generativeModel.generateContent(reqPayload);
        const rawText = result.response?.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
        console.log("Gemini Raw Response:", rawText);

        let parsedJson;
        try {
          parsedJson = JSON.parse(rawText);
        } catch (e1) {
          const match = rawText.match(/\{[\s\S]*\}/);
          if (match) {
            parsedJson = JSON.parse(match[0]);
          } else {
            throw new Error("Failed to parse JSON from Vertex AI response.");
          }
        }

        return res.status(200).json({
          success: true,
          model: "gemini-2.5-flash",
          provider: "Google Cloud Vertex AI",
          result: parsedJson,
        });
      } catch (error) {
        console.error("Vertex AI Verification Error:", error);
        return res.status(500).json({
          success: false,
          error: error.message || "Failed to analyze evidence with Vertex AI.",
        });
      }
    });
  }
);
