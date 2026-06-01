const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/studyshield')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.log('❌ MongoDB Error:', err));

// Routes
app.get('/', (req, res) => {
  res.json({
    message: '🎉 StudyShield API v1.0.0',
    status: 'running',
    endpoints: {
      auth: '/api/auth',
      users: '/api/users',
      sessions: '/api/sessions',
      analytics: '/api/analytics',
      appblocking: '/api/appblocking'
    }
  });
});

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Auth Routes
app.post('/api/auth/register', (req, res) => {
  res.json({ message: 'Register endpoint', status: 'coming soon' });
});

app.post('/api/auth/login', (req, res) => {
  res.json({ message: 'Login endpoint', status: 'coming soon' });
});

// Users Routes
app.get('/api/users/:id', (req, res) => {
  res.json({ message: 'Get user endpoint', status: 'coming soon' });
});

// Sessions Routes
app.post('/api/sessions/start', (req, res) => {
  res.json({ message: 'Start session endpoint', status: 'coming soon' });
});

app.post('/api/sessions/end', (req, res) => {
  res.json({ message: 'End session endpoint', status: 'coming soon' });
});

// Analytics Routes
app.get('/api/analytics/stats', (req, res) => {
  res.json({ message: 'Get analytics endpoint', status: 'coming soon' });
});

// App Blocking Routes
app.post('/api/appblocking/enable', (req, res) => {
  res.json({ message: 'Enable app blocking endpoint', status: 'coming soon' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 StudyShield Server running on port ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
});

module.exports = app;
