import { db } from './firebase-config.js';
import { requireAuth, formatMoney, formatDate } from './auth.js';
import {
  collection,
  query,
  where,
  orderBy,
  limit,
  getDocs,
  onSnapshot,
  Timestamp
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

requireAuth(async (user, adminData) => {
  // Set admin name
  document.getElementById('admin-name').textContent = adminData.name || user.email;
  document.getElementById('admin-initials').textContent = (adminData.name || 'A')[0].toUpperCase();

  // Load stats
  await loadStats();
  // Load recent bookings
  await loadRecentBookings();
  // Load pending providers
  await loadPendingProviders();
  // Start real-time counters
  setupRealtimeCounters();
});

async function loadStats() {
  try {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const monthTs = Timestamp.fromDate(monthStart);

    const [usersSnap, providersSnap, bookingsSnap, revenueSnap] = await Promise.all([
      getDocs(collection(db, 'users')),
      getDocs(query(collection(db, 'providers'), where('status', '==', 'active'))),
      getDocs(query(collection(db, 'bookings'), where('createdAt', '>=', monthTs))),
      getDocs(query(collection(db, 'payments'), where('createdAt', '>=', monthTs), where('status', '==', 'completed')))
    ]);

    document.getElementById('stat-users').textContent = usersSnap.size.toLocaleString();
    document.getElementById('stat-providers').textContent = providersSnap.size.toLocaleString();
    document.getElementById('stat-bookings').textContent = bookingsSnap.size.toLocaleString();

    let revenue = 0;
    revenueSnap.forEach(doc => { revenue += doc.data().amount || 0; });
    document.getElementById('stat-revenue').textContent = formatMoney(revenue);
  } catch (err) {
    console.error('Error loading stats:', err);
  }
}

async function loadRecentBookings() {
  try {
    const q = query(collection(db, 'bookings'), orderBy('createdAt', 'desc'), limit(10));
    const snap = await getDocs(q);

    const tbody = document.getElementById('recent-bookings');
    if (snap.empty) {
      tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:var(--text-muted);padding:30px">Нет данных</td></tr>';
      return;
    }

    tbody.innerHTML = snap.docs.map(doc => {
      const b = doc.data();
      const statusMap = {
        pending:   '<span class="badge badge-warning">Ожидание</span>',
        confirmed: '<span class="badge badge-info">Подтверждено</span>',
        completed: '<span class="badge badge-success">Завершено</span>',
        cancelled: '<span class="badge badge-danger">Отменено</span>'
      };
      return `
        <tr>
          <td class="td-main">#${doc.id.slice(-6).toUpperCase()}</td>
          <td>${b.clientName || '—'}</td>
          <td>${b.providerName || '—'}</td>
          <td>${b.serviceName || '—'}</td>
          <td>${statusMap[b.status] || b.status}</td>
          <td>${formatMoney(b.totalAmount)}</td>
        </tr>`;
    }).join('');
  } catch (err) {
    console.error('Error loading recent bookings:', err);
  }
}

async function loadPendingProviders() {
  try {
    const q = query(collection(db, 'providers'), where('status', '==', 'pending'), limit(5));
    const snap = await getDocs(q);

    const container = document.getElementById('pending-providers');
    if (snap.empty) {
      container.innerHTML = '<div class="empty-state"><div class="empty-icon">✓</div><p>Нет ожидающих заявок</p></div>';
      return;
    }

    container.innerHTML = snap.docs.map(doc => {
      const p = doc.data();
      return `
        <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border)">
          <div class="user-cell">
            <div class="avatar">${(p.name || 'P')[0].toUpperCase()}</div>
            <div>
              <div style="font-weight:500;color:var(--text-primary)">${p.name || '—'}</div>
              <div style="font-size:12px;color:var(--text-muted)">${p.category || '—'}</div>
            </div>
          </div>
          <div class="btn-group">
            <a href="providers.html?id=${doc.id}" class="btn btn-sm btn-outline">Просмотр</a>
          </div>
        </div>`;
    }).join('');
  } catch (err) {
    console.error('Error loading pending providers:', err);
  }
}

function setupRealtimeCounters() {
  // Real-time pending providers badge
  const pendingQ = query(collection(db, 'providers'), where('status', '==', 'pending'));
  onSnapshot(pendingQ, snap => {
    const badge = document.getElementById('pending-badge');
    if (badge) badge.textContent = snap.size > 0 ? snap.size : '';
  });

  // Real-time open disputes
  const disputeQ = query(collection(db, 'disputes'), where('status', '==', 'open'));
  onSnapshot(disputeQ, snap => {
    const badge = document.getElementById('disputes-badge');
    if (badge) badge.textContent = snap.size > 0 ? snap.size : '';
  });
}
