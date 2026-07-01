import jwt from 'jsonwebtoken';

export function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  
  const token = authHeader && authHeader.split(' ')[1]; // get token from "Bearer <token>"

  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.id; // attaches id and username to the request
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Invalid or expired token' });
  }
}