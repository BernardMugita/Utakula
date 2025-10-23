const express = require("express");
const router = express.Router(); // Use Router instead of express()
const { GoogleGenerativeAI } = require("@google/generative-ai");

router.post("/get_prep_instructions", async (req, res) => {
  const { contents } = req.body;

  try {
    const genAI = new GoogleGenerativeAI(process.env.API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const result = await model.generateContent(contents); // Pass the prompt correctly
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message || "Internal Server Error" });
  }
});

module.exports = router;
