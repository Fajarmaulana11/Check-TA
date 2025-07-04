const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");
const app = express();
app.use(cors());
app.use(express.json());

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Fungsi bantu buat format tanggal ke 'dd/MM/yyyy . HH:mm'
function formatTanggalUTC(timeString) {
    const date = new Date(timeString);
    const tgl = String(date.getUTCDate()).padStart(2, "0");
    const bln = String(date.getUTCMonth() + 1).padStart(2, "0");
    const thn = date.getUTCFullYear();
    const jam = String(date.getUTCHours()).padStart(2, "0");
    const menit = String(date.getUTCMinutes()).padStart(2, "0");
    return `${tgl}/${bln}/${thn} . ${jam}:${menit}`;
  }
  
  app.post("/api/kirim-data", async (req, res) => {
    try {
      console.log("Data diterima:", req.body);
  
      const { uid, activity, time } = req.body;
  
      if (!uid || !activity || !time) {
        return res.status(400).json({ success: false, message: "Data tidak lengkap" });
      }
  
      const formattedTime = formatTanggalUTC(time);
  
      await db.collection("history_parkir").add({
        uid,
        activity,
        time: formattedTime
      });
  
      return res.status(200).json({ success: true, message: "Data berhasil dikirim ke Firestore" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: error.message });
    }
  });
  

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
});
