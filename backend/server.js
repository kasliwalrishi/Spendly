
require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));

// ─── Firebase Admin initialization ─────────────────────────────

const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  throw new Error(
    "Set GOOGLE_APPLICATION_CREDENTIALS in backend/.env"
  );
}

const serviceAccount = require(path.resolve(serviceAccountPath));

initializeApp({
  credential: cert(serviceAccount),
});

const firebaseAuth = getAuth();

// ─── MongoDB models ────────────────────────────────────────────

const expenseSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    clientId: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
      maxlength: 120,
    },
    amount: {
      type: Number,
      required: true,
      min: 0.01,
    },
    category: {
      type: String,
      required: true,
      maxlength: 50,
    },
    date: {
      type: Date,
      required: true,
    },
    note: {
      type: String,
      default: "",
      maxlength: 1000,
    },
  },
  { timestamps: true }
);

// Prevent duplicate expense IDs for the same user.
expenseSchema.index(
  { userId: 1, clientId: 1 },
  { unique: true }
);

const Expense = mongoose.model("Expense", expenseSchema);

const budgetSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      unique: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  { timestamps: true }
);

const Budget = mongoose.model("Budget", budgetSchema);

// ─── Firebase authentication middleware ────────────────────────

async function authenticate(req, res, next) {
  try {
    const header = req.headers.authorization || "";
    const match = header.match(/^Bearer (.+)$/i);

    if (!match) {
      return res.status(401).json({
        error: "Authentication required",
      });
    }

    const decoded = await firebaseAuth.verifyIdToken(match[1]);

    // Never trust a user ID supplied in the request body.
    req.userId = decoded.uid;

    next();
  } catch (error) {
    return res.status(401).json({
      error: "Invalid or expired token",
    });
  }
}

// ─── Health check ──────────────────────────────────────────────

app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

// ─── Get all expenses for the authenticated user ───────────────

app.get("/api/expenses", authenticate, async (req, res, next) => {
  try {
    const expenses = await Expense.find({
      userId: req.userId,
    })
      .sort({ date: -1 })
      .lean();

    res.json(
      expenses.map((expense) => ({
        id: expense.clientId,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        note: expense.note,
      }))
    );
  } catch (error) {
    next(error);
  }
});

// ─── Create an expense ─────────────────────────────────────────

app.post("/api/expenses", authenticate, async (req, res, next) => {
  try {
    const {
      id,
      title,
      amount,
      category,
      date,
      note = "",
    } = req.body;

    if (
      typeof id !== "string" ||
      !id.trim() ||
      id.length > 128 ||
      typeof title !== "string" ||
      !title.trim() ||
      title.length > 120 ||
      typeof category !== "string" ||
      !category.trim() ||
      category.length > 50 ||
      typeof amount !== "number" ||
      !Number.isFinite(amount) ||
      amount <= 0 ||
      typeof date !== "string" ||
      Number.isNaN(Date.parse(date)) ||
      typeof note !== "string" ||
      note.length > 1000
    ) {
      return res.status(400).json({
        error: "Invalid expense data",
      });
    }

    const expense = await Expense.create({
      userId: req.userId,
      clientId: id.trim(),
      title: title.trim(),
      amount,
      category: category.trim(),
      date: new Date(date),
      note,
    });

    res.status(201).json({
      id: expense.clientId,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        error: "Expense ID already exists",
      });
    }

    next(error);
  }
});

// ─── Update an expense ─────────────────────────────────────────

app.put("/api/expenses/:id", authenticate, async (req, res, next) => {
  try {
    const {
      title,
      amount,
      category,
      date,
      note = "",
    } = req.body;

    if (
      typeof title !== "string" ||
      !title.trim() ||
      title.length > 120 ||
      typeof category !== "string" ||
      !category.trim() ||
      category.length > 50 ||
      typeof amount !== "number" ||
      !Number.isFinite(amount) ||
      amount <= 0 ||
      typeof date !== "string" ||
      Number.isNaN(Date.parse(date)) ||
      typeof note !== "string" ||
      note.length > 1000
    ) {
      return res.status(400).json({
        error: "Invalid expense data",
      });
    }

    const expense = await Expense.findOneAndUpdate(
      {
        userId: req.userId,
        clientId: req.params.id,
      },
      {
        title: title.trim(),
        amount,
        category: category.trim(),
        date: new Date(date),
        note,
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!expense) {
      return res.status(404).json({
        error: "Expense not found",
      });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// ─── Delete an expense ─────────────────────────────────────────

app.delete(
  "/api/expenses/:id",
  authenticate,
  async (req, res, next) => {
    try {
      const result = await Expense.deleteOne({
        userId: req.userId,
        clientId: req.params.id,
      });

      if (!result.deletedCount) {
        return res.status(404).json({
          error: "Expense not found",
        });
      }

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  }
);

// ─── Get the authenticated user's budget ───────────────────────

app.get("/api/budget", authenticate, async (req, res, next) => {
  try {
    const budget = await Budget.findOne({
      userId: req.userId,
    }).lean();

    res.json({
      amount: budget ? budget.amount : 0,
    });
  } catch (error) {
    next(error);
  }
});

// ─── Create or update the authenticated user's budget ──────────

app.put("/api/budget", authenticate, async (req, res, next) => {
  try {
    const { amount } = req.body;

    if (
      typeof amount !== "number" ||
      !Number.isFinite(amount) ||
      amount < 0
    ) {
      return res.status(400).json({
        error: "Invalid budget amount",
      });
    }

    await Budget.findOneAndUpdate(
      { userId: req.userId },
      { amount },
      {
        upsert: true,
        new: true,
        runValidators: true,
      }
    );

    res.json({ amount });
  } catch (error) {
    next(error);
  }
});

// ─── Central error handler ─────────────────────────────────────

app.use((error, req, res, next) => {
  console.error("API error:", error.message);

  if (res.headersSent) {
    return next(error);
  }

  res.status(500).json({
    error: "Internal server error",
  });
});

// ─── Start server ──────────────────────────────────────────────

const PORT = Number(process.env.PORT) || 3000;

async function start() {
  if (!process.env.MONGODB_URI) {
    throw new Error("Set MONGODB_URI in backend/.env");
  }

  await mongoose.connect(process.env.MONGODB_URI);

  console.log("MongoDB connected");

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Spendly API listening on port ${PORT}`);
  });
}

start().catch((error) => {
  console.error("Backend startup failed:", error.message);
  process.exit(1);
});
