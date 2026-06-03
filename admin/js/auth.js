import { auth, db } from './firebase-config.js';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";
import { doc, getDoc } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const ADMIN_EMAILS = ['admin@qyzmet.kz', 'superadmin@qyzmet.kz'];

// Check if user is logged in and is admin
export function requireAuth(callback) {
  onAuthStateChanged(auth, async (user) => {
    if (!user) {
      window.location.href = '/admin/index.html';
      return;
    }

    // Verify admin role in Firestore
    try {
      const adminDoc = await getDoc(doc(db, 'admins', user.uid));
      if (!adminDoc.exists()) {
        await signOut(auth);
        window.location.href = '/admin/index.html?error=unauthorized';
        return;
      }
      callback(user, adminDoc.data());
    } catch (err) {
      console.error('Auth check failed:', err);
      window.location.href = '/admin/index.html?error=auth_failed';
    }
  });
}

// Login function
export async function login(email, password) {
  const userCred = await signInWithEmailAndPassword(auth, email, password);
  const adminDoc = await getDoc(doc(db, 'admins', userCred.user.uid));
  if (!adminDoc.exists()) {
    await signOut(auth);
    throw new Error('Доступ запрещен. Только для администраторов.');
  }
  return userCred.user;
}

// Logout function
export async function logout() {
  await signOut(auth);
  window.location.href = '/admin/index.html';
}

// Toast notifications
export function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container') ||
    (() => {
      const c = document.createElement('div');
      c.id = 'toast-container';
      c.className = 'toast-container';
      document.body.appendChild(c);
      return c;
    })();

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;

  const icons = { success: '✓', error: '✗', info: 'ℹ' };
  toast.innerHTML = `<span>${icons[type] || 'ℹ'}</span> ${message}`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(100%)';
    toast.style.transition = '0.3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// Format helpers
export function formatDate(ts) {
  if (!ts) return '—';
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

export function formatMoney(amount) {
  return new Intl.NumberFormat('ru-RU', { style: 'currency', currency: 'KZT', maximumFractionDigits: 0 }).format(amount || 0);
}

export function getInitials(name) {
  if (!name) return '?';
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
}
