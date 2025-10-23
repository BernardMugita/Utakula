const cors = require("cors");
const dotenv = require("dotenv");
const express = require("express"); // Correctly require express
const foodRoutes = require("./controllers/food_controller");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Where is the food!");
});

app.use("/utakula/foods", foodRoutes);

app.listen(8080, () => {
  console.log("Server running on http://localhost:8080");
});
