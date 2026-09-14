const { onRequest } = require("firebase-functions/v2/https");
const { VertexAI } = require("@google-cloud/vertexai");
const { jsonrepair } = require("jsonrepair");
const cors = require("cors")({ origin: true });

// Initialize Vertex AI on GCP Project hersh-karma
const PROJECT_ID = process.env.GCLOUD_PROJECT || "hersh-karma";
const LOCATION = "us-central1";

const vertexAI = new VertexAI({
  project: PROJECT_ID,
  location: LOCATION,
});

function detectMimeType(base64Str) {
  if (base64Str.startsWith("/9j/")) return "image/jpeg";
  if (base64Str.startsWith("iVBORw")) return "image/png";
  if (base64Str.startsWith("UklGR")) return "image/webp";
  if (base64Str.startsWith("R0lGOD")) return "image/gif";
  return "image/jpeg";
}

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

        const mimeBefore = detectMimeType(cleanBefore);
        const mimeAfter = detectMimeType(cleanAfter);

        const generativeModel = vertexAI.getGenerativeModel({
          model: "gemini-2.5-flash",
          generationConfig: {
            responseMimeType: "application/json",
            temperature: 0.1,
            maxOutputTokens: 4096,
          },
        });

        const prompt = `You are the Proof-of-Good AI Multimodal Vision & Object Recognition Engine for the Karma Grid ecosystem.
Examine Photo 1 (BEFORE) and Photo 2 (AFTER).

Deed Title: "${deedTitle}"
Category: "${category}"
Description: "${description || 'Community impact deed'}"
GPS Coordinates: ${latitude && longitude ? `${latitude}, ${longitude}` : 'Verified enclave'}

OBJECT RECOGNITION & VERIFICATION INSTRUCTIONS:
1. Object Detection:
   - Identify every physical object, living creature, furniture, tool, vehicle, material, or waste item in Photo 1 and output as a list in 'detectedObjectsBefore'.
   - Identify every physical object, living creature, furniture, tool, vehicle, material, or waste item in Photo 2 and output as a list in 'detectedObjectsAfter'.
2. Visual Scene Description:
   - Provide concise 1-2 sentence description of Photo 1 in 'whatSeenBefore'.
   - Provide concise 1-2 sentence description of Photo 2 in 'whatSeenAfter'.
3. Real Difference & Action:
   - Describe the exact physical difference/transformation between Photo 1 and Photo 2 in 'visualDifference'.
   - If Photo 1 and Photo 2 are identical, unchanged, or show bare floors/walls with no action:
     * isGoodDeedDetected = false
     * evidenceScore = 20
     * isTampered = true
     * visualDifference = "0% difference - identical or unchanged photos"
     * changeSummary = "Unchanged photos uploaded: No positive transformation detected."
     * reasoning = "Both photos show the same scene with no visible deed or transformation."
   - If a genuine good deed is observed matching "${category}":
     * isGoodDeedDetected = true
     * evidenceScore = 92
     * isTampered = false
     * changeSummary = "Concise summary of verified impact"
     * reasoning = "Explanation of confirmed transformation and scene match."

Return valid JSON adhering to this structure:
{
  "whatSeenBefore": "Concise scene description of Photo 1",
  "whatSeenAfter": "Concise scene description of Photo 2",
  "detectedObjectsBefore": ["item 1", "item 2", "item 3"],
  "detectedObjectsAfter": ["item 1", "item 2", "item 3"],
  "visualDifference": "Detailed visual change between both photos",
  "isGoodDeedDetected": true,
  "evidenceScore": 92,
  "sceneMatchConfidence": 0.95,
  "changeSummary": "Summary of deed",
  "measurableBefore": "Baseline state",
  "measurableAfter": "Outcome state",
  "isTampered": false,
  "reasoning": "Verdict reasoning"
}`;

        const reqPayload = {
          contents: [
            {
              role: "user",
              parts: [
                { text: prompt },
                {
                  inlineData: {
                    mimeType: mimeBefore,
                    data: cleanBefore,
                  },
                },
                {
                  inlineData: {
                    mimeType: mimeAfter,
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
          // Attempt standard JSON parse
          parsedJson = JSON.parse(rawText);
        } catch (e1) {
          try {
            // Attempt jsonrepair
            const repaired = jsonrepair(rawText);
            parsedJson = JSON.parse(repaired);
          } catch (e2) {
            console.error("jsonrepair error:", e2);
            const match = rawText.match(/\{[\s\S]*\}/);
            if (match) {
              const repairedMatch = jsonrepair(match[0]);
              parsedJson = JSON.parse(repairedMatch);
            } else {
              throw new Error("Failed to parse JSON from Vertex AI response.");
            }
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
