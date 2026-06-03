import { db } from './firebase-config.js';
import { requireAuth, showToast, formatDate, formatMoney } from './auth.js';
import {
  collection,
  query,
  where,
  orderBy,
  getDocs,
  getDoc,
  doc,
  updateDoc,
  serverTimestamp,
  limit,
  startAfter
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const PAGE_SIZE = 20;
let lastDoc = null;
let currentFilter = 'all';
let allBookings = [];

requireAuth(async (user, adminData) => {
  document.getElementById('admin-name').textContent = adminData.name || user.email;
  document.getElementById('admin-initials').textContent = (adminData.name || 'A')[0].toUpperCase();
  await loadBookings();
  setupFilters();
});

async function loadBookings(loadMore = false) {
  if (!loadMore) {
    lastDoc = null;
    allBookings = [];
  }

  const tbody = document.getElementById('bookings-table');
  if (!loadMore) {
    tbody.innerHTML = '<tr><td colspan="8"><div class="loading"><div class="spinner"></div> Загрузка...</div></td></tr>';
  }

  try {
    let constraints = [orderBy('createdAt', 'desc'), limit(PAGE_SIZE)];
    if (currentFilter !== 'all') constraints.unshift(where('status', '==', currentFilter));
    if (lastDoc) constraints.push(startAfter(lastDoc));

    const snap = await getDocs(query(collection(db, 'bookings'), ...constraints));
    if (!snap.empty) lastDoc = snap.docs[snap.docs.length - 1];

    const newBookings = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    allBookings = loadMore ? [...allBookings, ...newBookings] : newBookings;
    renderBookings(allBookings);

    document.getElementById('load-more-btn').style.display = snap.size < PAGE_SIZE ? 'none' : 'block';
    document.getElementById('total-count').textContent = `Загружено: ${allBookings.length}`;
  } catch (err) {
    console.error(err);
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:var(--danger);padding:30px">Ошибка загрузки</td></tr>';
  }
}

function renderBookings(bookings) {
  const tbody = document.getElementById('bookings-table');
  if (!bookings.length) {
    tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><div class="empty-icon">📋</div><p>Нет бронирований</p></div></td></tr>';
    return;
  }

  const statusMap = {
    pending:   '<span class="badge badge-warning">Ожидание</span>',
    confirmed: '<span class="badge badge-info">Подтверждено</span>',
    in_progress:'<span class="badge badge-accent">В процессе</span>',
    completed: '<span class="badge badge-success">Завершено</span>',
    cancelled: '<span class="badge badge-danger">Отменено</span>',
    disputed:  '<span class="badge badge-danger">Спор</span>'
  };

  tbody.innerHTML = bookings.map(b => `
    <tr>
      <td class="td-main">#${b.id.slice(-6).toUpperCase()}</td>
      <td>${b.clientName || '—'}</td>
      <td>${b.providerName || '—'}</td>
      <td>${b.serviceName || '—'}</td>
      <td>${formatDate(b.scheduledAt)}</td>
      <td>${statusMap[b.status] || b.status}</td>
      <td>${formatMoney(b.totalAmount)}</td>
      <td>
        <div class="btn-group">
          <button class="btn btn-sm btn-outline" onclick="viewBooking('${b.id}')">Детали</button>
          ${b.status === 'disputed' ? `<button class="btn btn-sm btn-warning" onclick="resolveDispute('${b.id}')">Решить</button>` : ''}
          ${['pending','confirmed'].includes(b.status) ? `<button class="btn btn-sm btn-danger" onclick="cancelBooking('${b.id}')">Отменить</button>` : ''}
        </div>
      </td>
    </tr>`).join('');
}

function setupFilters() {
  document.querySelectorAll('.filter-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      currentFilter = tab.dataset.filter;
      loadBookings();
    });
  });

  document.getElementById('search-input')?.addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase();
    const filtered = allBookings.filter(b =>
      b.id.toLowerCase().includes(term) ||
      (b.clientName || '').toLowerCase().includes(term) ||
      (b.providerName || '').toLowerCase().includes(term)
    );
    renderBookings(filtered);
  });

  document.getElementById('load-more-btn')?.addEventListener('click', () => loadBookings(true));
}

window.viewBooking = async (id) => {
  try {
    const snap = await getDoc(doc(db, 'bookings', id));
    if (!snap.exists()) return;
    const b = snap.data();

    document.getElementById('modal-booking-id').textContent = `#${id.slice(-6).toUpperCase()}`;
    document.getElementById('modal-booking-details').innerHTML = `
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px">
        <div><div style="font-size:11px;color:var(--text-muted)">КЛИЕНТ</div><div>${b.clientName || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted)">ПОСТАВЩИК</div><div>${b.providerName || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted)">УСЛУГА</div><div>${b.serviceName || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted)">СУММА</div><div>${formatMoney(b.totalAmount)}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted)">ДАТА</div><div>${formatDate(b.scheduledAt)}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted)">СТАТУС</div><div>${b.status}</div></div>
        <div style="grid-column:span 2"><div style="font-size:11px;color:var(--text-muted)">АДРЕС</div><div>${b.address || '—'}</div></div>
        ${b.cancelReason ? `<div style="grid-column:span 2"><div style="font-size:11px;color:var(--text-muted)">ПРИЧИНА ОТМЕНЫ</div><div style="color:var(--danger)">${b.cancelReason}</div></div>` : ''}
      </div>`;

    document.getElementById('booking-modal').classList.add('open');
  } catch (err) {
    showToast('Ошибка загрузки', 'error');
  }
};

window.closeModal = () => {
  document.getElementById('booking-modal')?.classList.remove('open');
};

window.cancelBooking = async (id) => {
  const reason = prompt('Причина отмены:');
  if (reason === null) return;
  try {
    await updateDoc(doc(db, 'bookings', id), {
      status: 'cancelled',
      cancelReason: reason,
      cancelledBy: 'admin',
      cancelledAt: serverTimestamp()
    });
    showToast('Бронирование отменено', 'info');
    loadBookings();
  } catch (err) {
    showToast('Ошибка', 'error');
  }
};

window.resolveDispute = async (id) => {
  const resolution = prompt('Решение спора:');
  if (resolution === null) return;
  try {
    await updateDoc(doc(db, 'bookings', id), {
      status: 'completed',
      disputeResolution: resolution,
      disputeResolvedAt: serverTimestamp(),
      disputeResolvedBy: 'admin'
    });
    showToast('Спор решен', 'success');
    loadBookings();
  } catch (err) {
    showToast('Ошибка', 'error');
  }
};
