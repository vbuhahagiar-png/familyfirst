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
  onSnapshot
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

let currentFilter = 'all';
let allProviders = [];

requireAuth(async (user, adminData) => {
  document.getElementById('admin-name').textContent = adminData.name || user.email;
  document.getElementById('admin-initials').textContent = (adminData.name || 'A')[0].toUpperCase();

  await loadProviders();
  setupSearch();
  checkUrlParams();
});

async function loadProviders() {
  const tbody = document.getElementById('providers-table');
  tbody.innerHTML = '<tr><td colspan="7"><div class="loading"><div class="spinner"></div> Загрузка...</div></td></tr>';

  try {
    let q = collection(db, 'providers');
    if (currentFilter !== 'all') {
      q = query(q, where('status', '==', currentFilter), orderBy('createdAt', 'desc'));
    } else {
      q = query(q, orderBy('createdAt', 'desc'));
    }

    const snap = await getDocs(q);
    allProviders = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    renderProviders(allProviders);

    document.getElementById('total-count').textContent = `Всего: ${allProviders.length}`;
  } catch (err) {
    console.error(err);
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:var(--danger);padding:30px">Ошибка загрузки</td></tr>';
  }
}

function renderProviders(providers) {
  const tbody = document.getElementById('providers-table');
  if (!providers.length) {
    tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state"><div class="empty-icon">👤</div><p>Нет поставщиков</p></div></td></tr>';
    return;
  }

  const statusMap = {
    pending:   '<span class="badge badge-warning">На проверке</span>',
    active:    '<span class="badge badge-success">Активен</span>',
    suspended: '<span class="badge badge-danger">Заблокирован</span>',
    rejected:  '<span class="badge badge-muted">Отклонен</span>'
  };

  tbody.innerHTML = providers.map(p => `
    <tr>
      <td>
        <div class="user-cell">
          <div class="avatar">${(p.name || 'P')[0].toUpperCase()}</div>
          <div>
            <div class="td-main">${p.name || '—'}</div>
            <div style="font-size:12px;color:var(--text-muted)">${p.email || ''}</div>
          </div>
        </div>
      </td>
      <td>${p.category || '—'}</td>
      <td>${p.city || '—'}</td>
      <td>${statusMap[p.status] || p.status}</td>
      <td>⭐ ${(p.rating || 0).toFixed(1)} (${p.reviewCount || 0})</td>
      <td>${formatMoney(p.totalEarnings)}</td>
      <td>
        <div class="btn-group">
          <button class="btn btn-sm btn-outline" onclick="viewProvider('${p.id}')">Просмотр</button>
          ${p.status === 'pending' ? `
            <button class="btn btn-sm btn-success" onclick="approveProvider('${p.id}')">✓ Одобрить</button>
            <button class="btn btn-sm btn-danger" onclick="rejectProvider('${p.id}')">✗ Отклонить</button>
          ` : ''}
          ${p.status === 'active' ? `
            <button class="btn btn-sm btn-warning" onclick="suspendProvider('${p.id}')">⏸ Приостановить</button>
          ` : ''}
          ${p.status === 'suspended' ? `
            <button class="btn btn-sm btn-success" onclick="reactivateProvider('${p.id}')">▶ Восстановить</button>
          ` : ''}
        </div>
      </td>
    </tr>`).join('');
}

function setupSearch() {
  const searchInput = document.getElementById('search-input');
  searchInput?.addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase();
    const filtered = allProviders.filter(p =>
      (p.name || '').toLowerCase().includes(term) ||
      (p.email || '').toLowerCase().includes(term) ||
      (p.category || '').toLowerCase().includes(term) ||
      (p.city || '').toLowerCase().includes(term)
    );
    renderProviders(filtered);
  });

  document.querySelectorAll('.filter-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      currentFilter = tab.dataset.filter;
      loadProviders();
    });
  });
}

function checkUrlParams() {
  const params = new URLSearchParams(window.location.search);
  const id = params.get('id');
  if (id) viewProvider(id);
}

window.viewProvider = async (id) => {
  try {
    const snap = await getDoc(doc(db, 'providers', id));
    if (!snap.exists()) return;
    const p = snap.data();

    document.getElementById('modal-provider-name').textContent = p.name || '—';
    document.getElementById('modal-provider-details').innerHTML = `
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px">
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">EMAIL</div><div>${p.email || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">ТЕЛЕФОН</div><div>${p.phone || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">КАТЕГОРИЯ</div><div>${p.category || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">ГОРОД</div><div>${p.city || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">ИИН</div><div>${p.iin || '—'}</div></div>
        <div><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">ОПЫТ</div><div>${p.experience || '—'} лет</div></div>
      </div>
      <div style="margin-bottom:12px"><div style="font-size:11px;color:var(--text-muted);margin-bottom:4px">О СЕБЕ</div><div style="color:var(--text-secondary)">${p.bio || '—'}</div></div>
      <div style="margin-bottom:12px"><div style="font-size:11px;color:var(--text-muted);margin-bottom:6px">ДОКУМЕНТЫ</div>
        ${p.idDocumentUrl ? `<a href="${p.idDocumentUrl}" target="_blank" class="btn btn-sm btn-outline">📄 Удостоверение личности</a>` : '<span style="color:var(--text-muted)">Нет документов</span>'}
      </div>
      <div style="display:flex;gap:10px;margin-top:16px">
        ${p.status === 'pending' ? `
          <button class="btn btn-success" onclick="approveProvider('${id}');closeModal()">✓ Одобрить</button>
          <button class="btn btn-danger" onclick="rejectProvider('${id}');closeModal()">✗ Отклонить</button>
        ` : ''}
      </div>`;

    document.getElementById('provider-modal').classList.add('open');
  } catch (err) {
    showToast('Ошибка загрузки данных', 'error');
  }
};

window.closeModal = () => {
  document.getElementById('provider-modal').classList.remove('open');
};

window.approveProvider = async (id) => {
  try {
    await updateDoc(doc(db, 'providers', id), {
      status: 'active',
      approvedAt: serverTimestamp(),
      approvedBy: 'admin'
    });
    showToast('Поставщик одобрен', 'success');
    loadProviders();
  } catch (err) {
    showToast('Ошибка при одобрении', 'error');
  }
};

window.rejectProvider = async (id) => {
  const reason = prompt('Причина отказа:');
  if (reason === null) return;
  try {
    await updateDoc(doc(db, 'providers', id), {
      status: 'rejected',
      rejectionReason: reason,
      rejectedAt: serverTimestamp()
    });
    showToast('Поставщик отклонен', 'info');
    loadProviders();
  } catch (err) {
    showToast('Ошибка при отклонении', 'error');
  }
};

window.suspendProvider = async (id) => {
  if (!confirm('Приостановить аккаунт поставщика?')) return;
  try {
    await updateDoc(doc(db, 'providers', id), { status: 'suspended', suspendedAt: serverTimestamp() });
    showToast('Аккаунт приостановлен', 'info');
    loadProviders();
  } catch (err) {
    showToast('Ошибка', 'error');
  }
};

window.reactivateProvider = async (id) => {
  try {
    await updateDoc(doc(db, 'providers', id), { status: 'active', reactivatedAt: serverTimestamp() });
    showToast('Аккаунт восстановлен', 'success');
    loadProviders();
  } catch (err) {
    showToast('Ошибка', 'error');
  }
};
