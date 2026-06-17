// ===== STATE =====
let currentLang = 'ru';
let currentRole = 'client';
const noStatusBar = ['welcome','splash','onboarding','login','phone-auth','confirmation'];
const noTop = new Set(noStatusBar);

const screenNames = {
  welcome:'Bienvenue', splash:'Splash', onboarding:'Onboarding', login:'Connexion','phone-auth':'Auth téléphone',
  home:'Accueil', search:'Recherche','providers-list':'Liste prestataires','provider-detail':'Profil prestataire',
  booking:'Réservation', payment:'Paiement', confirmation:'Confirmation', track:'Suivi réservation',
  bookings:'Mes réservations', profile:'Profil', premium:'Qyzmet Premium', notifications:'Notifications', chat:'Assistant Qyzmet',
  'provider-home':'Tableau de bord', 'provider-kyc':'Vérification KYC','provider-bookings':'Mes missions','provider-earnings':'Revenus'
};

function goTo(screen) {
  document.querySelectorAll('.screen').forEach(el => el.classList.remove('active'));
  const el = document.getElementById('screen-' + screen);
  if (!el) return;
  el.classList.add('active');
  const hasBar = !noStatusBar.includes(screen);
  const sb = document.getElementById('sb');
  if (sb) sb.style.display = hasBar ? 'flex' : 'none';
  document.getElementById('breadcrumb').textContent = 'Écran : ' + (screenNames[screen] || screen);
  const sc = el.querySelector('.screen-scroll');
  if (sc) sc.scrollTop = 0;
}

// ===== WELCOME: LANG + ROLE =====
function openLangModal() { document.getElementById('lang-modal').classList.add('active'); }
function closeLangModal() { document.getElementById('lang-modal').classList.remove('active'); }
function selectLang(code, label) {
  currentLang = code;
  document.querySelectorAll('.lang-modal-item').forEach(i => i.classList.remove('sel'));
  const item = document.getElementById('lang-' + code);
  if (item) item.classList.add('sel');
  const welcomeLabel = document.getElementById('welcome-lang-label');
  if (welcomeLabel) welcomeLabel.textContent = label;
  const profileLabel = document.getElementById('profile-lang-label');
  if (profileLabel) profileLabel.textContent = label;
  closeLangModal();
}
function selectRole(role) {
  currentRole = role;
  if (role === 'provider') {
    document.getElementById('login-role-tag').textContent = 'Espace Prestataire';
    goTo('login');
  } else {
    document.getElementById('login-role-tag').textContent = 'Espace Client';
    goTo('onboarding');
  }
}
function loginAs() {
  goTo(currentRole === 'provider' ? 'provider-home' : 'home');
}

// ===== ONBOARDING =====
let slide = 0;
function nextSlide() {
  document.getElementById('sl' + slide).classList.remove('active');
  document.getElementById('od' + slide).classList.remove('active');
  if (slide < 2) {
    slide++;
    document.getElementById('sl' + slide).classList.add('active');
    document.getElementById('od' + slide).classList.add('active');
    document.getElementById('ob-next').textContent = slide === 2 ? 'Commencer →' : 'Suivant →';
  } else {
    slide = 0;
    document.getElementById('sl0').classList.add('active');
    document.getElementById('od0').classList.add('active');
    document.getElementById('ob-next').textContent = 'Suivant →';
    goTo('login');
  }
}

function showOTP() { document.getElementById('otp-section').style.display = 'block'; }

// ===== FILTER CHIPS =====
document.addEventListener('click', e => {
  if (e.target.classList.contains('chip') && e.target.closest('.filters-scroll')) {
    e.target.closest('.filters-scroll').querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
    e.target.classList.add('active');
  }
});

// ===== DETAIL TABS =====
function switchTab(i) {
  document.querySelectorAll('.dtab').forEach((t, j) => t.classList.toggle('active', i === j));
  document.querySelectorAll('.tcontent').forEach((c, j) => c.classList.toggle('active', i === j));
}

// ===== BOOKING TABS (different content per tab) =====
function switchBookingTab(tab) {
  document.querySelectorAll('.htab').forEach(t => t.classList.toggle('active', t.dataset.tab === tab));
  document.querySelectorAll('.bk-tabpanel').forEach(p => p.classList.toggle('active', p.id === 'panel-' + tab));
}

// ===== DATE CHIPS (booking) =====
function buildDateChips() {
  const c = document.getElementById('dchips');
  if (!c || c.children.length) return;
  const days = ['Dim','Lun','Mar','Mer','Jeu','Ven','Sam'];
  const today = new Date();
  for (let i = 0; i < 7; i++) {
    const d = new Date(today); d.setDate(today.getDate() + i);
    const chip = document.createElement('div');
    chip.className = 'dchip' + (i === 1 ? ' sel' : '');
    chip.innerHTML = `<div class="dn">${days[d.getDay()]}</div><div class="dd">${d.getDate()}</div>`;
    chip.onclick = () => { document.querySelectorAll('.dchip').forEach(x => x.classList.remove('sel')); chip.classList.add('sel'); };
    c.appendChild(chip);
  }
}

function selTime(el) {
  if (el.classList.contains('taken')) return;
  el.closest('.time-grid').querySelectorAll('.tslot:not(.taken)').forEach(s => s.classList.remove('sel'));
  el.classList.add('sel');
}

function selDur(el, dur) {
  el.closest('.dur-sel').querySelectorAll('.dur-btn').forEach(b => b.classList.remove('sel'));
  el.classList.add('sel');
  const total = document.getElementById('bk-total');
  if (total) total.textContent = (3500 * dur).toLocaleString('fr') + ' ₸';
  const sub = document.getElementById('bk-sub');
  if (sub) sub.textContent = '3 500 ₸ × ' + dur + 'h';
}

// ===== PAYMENT =====
function selPay(el) {
  document.querySelectorAll('.pay-method').forEach(m => m.classList.remove('sel'));
  el.classList.add('sel');
  document.getElementById('card-fields').style.display = el.querySelector('.pay-icon').textContent.includes('💳') ? 'block' : 'none';
}

function processPayment() {
  document.getElementById('pay-loading').style.display = 'flex';
  document.getElementById('pay-sticky').style.display = 'none';
  setTimeout(() => {
    document.getElementById('pay-loading').style.display = 'none';
    document.getElementById('pay-sticky').style.display = 'block';
    goTo('confirmation');
  }, 2200);
}

// ===== PREMIUM PLAN TOGGLE =====
function togglePremiumPlan(plan) {
  document.querySelectorAll('.plan-toggle button').forEach(b => b.classList.remove('sel'));
  document.getElementById('plan-' + plan).classList.add('sel');
  const priceEl = document.getElementById('premium-price-val');
  if (plan === 'monthly') {
    priceEl.innerHTML = '2 990 ₸ <small>/mois</small>';
    document.getElementById('premium-old').style.display = 'inline';
    document.getElementById('premium-save').style.display = 'none';
  } else {
    priceEl.innerHTML = '1 990 ₸ <small>/mois</small>';
    document.getElementById('premium-old').style.display = 'none';
    document.getElementById('premium-save').style.display = 'inline';
  }
}

// ===== KYC FLOW =====
let kycStep = 1;
function kycUpload(el, label) {
  el.classList.add('filled');
  el.querySelector('h5').textContent = label + ' ✓ Téléchargé';
  el.querySelector('.uic').textContent = '✅';
}
function kycNext(step) {
  document.getElementById('kyc-panel-' + kycStep).style.display = 'none';
  kycStep = step;
  document.getElementById('kyc-panel-' + kycStep).style.display = 'block';
  for (let i = 1; i <= 4; i++) {
    document.getElementById('kyc-bar-' + i).classList.toggle('done', i <= kycStep);
  }
  document.getElementById('kyc-step-label').textContent = 'Étape ' + kycStep + ' / 4';
}

// ===== AI CHAT =====
const chatResponses = {
  default: "Merci pour votre message ! Notre équipe support va analyser votre demande. En attendant, voici ce que je peux vous dire : Qyzmet garantit un remboursement intégral en cas d'annulation par le prestataire, et tous nos professionnels sont vérifiés (pièce d'identité + entretien).",
  paiement: "💳 Le paiement est sécurisé via Stripe (cryptage SSL). Vous pouvez payer par carte bancaire, Apple Pay ou Google Pay. Le montant n'est débité qu'après confirmation du prestataire, et vous êtes intégralement remboursé en cas d'annulation de sa part.",
  annulation: "📅 Vous pouvez annuler gratuitement jusqu'à 2h avant le rendez-vous (24h pour les membres Premium). Au-delà, des frais de 30% peuvent s'appliquer pour indemniser le prestataire.",
  kyc: "🪪 Pour devenir prestataire vérifié, il faut fournir : pièce d'identité (recto/verso), selfie de vérification, justificatif de domicile et casier judiciaire vierge (pour baby-sitting). La validation prend en général 24h.",
  cashback: "🎁 Vous gagnez 5% de cashback en Qyzmet Coins sur chaque réservation, utilisables sur vos prochaines commandes. Les membres Premium gagnent 10% !",
  premium: "✨ Qyzmet Premium à 2 990 ₸/mois (ou 1 990 ₸/mois en annuel) vous donne : -15% sur toutes les réservations, support prioritaire 24/7, annulation gratuite jusqu'à 2h avant, et accès prioritaire aux meilleurs prestataires.",
  suivi: "📍 Une fois votre réservation confirmée, vous pouvez suivre son statut en temps réel dans l'onglet « Mes réservations » : Réservation confirmée → Prestataire en route → Mission en cours → Mission terminée. Vous recevez une notification à chaque étape.",
  revenus: "💼 En tant que prestataire, vous voyez vos revenus en temps réel dans l'onglet « Revenus » : gains du jour, de la semaine et du mois. Les paiements sont versés automatiquement sur votre compte sous 24-48h après chaque mission via Stripe.",
  litige: "⚠️ Je suis désolé d'apprendre ça. Pour un litige (prestation non conforme, retard, comportement), décrivez le problème ici et notre équipe support humaine sera automatiquement notifiée pour examiner votre dossier sous 24h. Vous pouvez aussi cliquer sur « Humain » en haut de ce chat pour parler directement à un agent."
};

function sendQuickMsg(text, key) {
  addUserMsg(text);
  showTyping();
  setTimeout(() => {
    hideTyping();
    addBotMsg(chatResponses[key] || chatResponses.default);
  }, 1300);
}

function sendChatMsg() {
  const input = document.getElementById('chat-input');
  const text = input.value.trim();
  if (!text) return;
  addUserMsg(text);
  input.value = '';
  showTyping();
  setTimeout(() => {
    hideTyping();
    let key = 'default';
    const lower = text.toLowerCase();
    if (lower.includes('paiement') || lower.includes('payer') || lower.includes('carte')) key = 'paiement';
    else if (lower.includes('annul')) key = 'annulation';
    else if (lower.includes('kyc') || lower.includes('document') || lower.includes('vérif')) key = 'kyc';
    else if (lower.includes('cashback') || lower.includes('coin')) key = 'cashback';
    else if (lower.includes('premium')) key = 'premium';
    else if (lower.includes('suivi') || lower.includes('track') || lower.includes('où en est')) key = 'suivi';
    else if (lower.includes('revenu') || lower.includes('gagne') || lower.includes('paie') && lower.includes('prestataire')) key = 'revenus';
    else if (lower.includes('litige') || lower.includes('problème') || lower.includes('plainte')) key = 'litige';
    addBotMsg(chatResponses[key]);
  }, 1300);
}

function addUserMsg(text) {
  const msgs = document.getElementById('chat-msgs');
  const div = document.createElement('div');
  div.className = 'msg user';
  div.textContent = text;
  msgs.appendChild(div);
  msgs.scrollTop = msgs.scrollHeight;
}
function addBotMsg(text) {
  const msgs = document.getElementById('chat-msgs');
  const div = document.createElement('div');
  div.className = 'msg bot';
  div.textContent = text;
  msgs.appendChild(div);
  msgs.scrollTop = msgs.scrollHeight;
}
function showTyping() {
  const msgs = document.getElementById('chat-msgs');
  const div = document.createElement('div');
  div.className = 'typing-dots';
  div.id = 'typing-indicator';
  div.innerHTML = '<span></span><span></span><span></span>';
  msgs.appendChild(div);
  msgs.scrollTop = msgs.scrollHeight;
}
function hideTyping() {
  const t = document.getElementById('typing-indicator');
  if (t) t.remove();
}

// ===== PROVIDER: AVAILABILITY SWITCH =====
function toggleAvailSwitch(el) {
  el.classList.toggle('on');
  const statusText = document.getElementById('avail-status-text');
  if (statusText) statusText.textContent = el.classList.contains('on') ? 'Disponible maintenant' : 'Hors ligne';
}

function acceptRequest(el) {
  el.querySelector('.req-actions').innerHTML = '<div class="badge badge-success" style="padding:8px 14px;font-size:13px">✓ Mission acceptée</div>';
}
function declineRequest(el) {
  el.style.opacity = '0.4';
  el.querySelector('.req-actions').innerHTML = '<div class="badge badge-gray" style="padding:8px 14px;font-size:13px">Refusée</div>';
}

// ===== CONTACT MODAL =====
function openContactModal() { document.getElementById('contact-modal').classList.add('active'); }
function closeContactModal() { document.getElementById('contact-modal').classList.remove('active'); }

// ===== INIT =====
document.addEventListener('DOMContentLoaded', () => {
  goTo('welcome');
  buildDateChips();
});
