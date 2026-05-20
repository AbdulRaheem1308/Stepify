import { Controller, Get, Post, Body, Header, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { StepsService } from '../steps/steps.service';

@Controller('admin')
export class AdminController {
    constructor(
        private prisma: PrismaService,
        private redisService: RedisService,
        private stepsService: StepsService,
    ) { }

    @Get()
    @Header('Content-Type', 'text/html')
    async getDashboardHtml() {
        return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stepify - Premium Admin Console</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.socket.io/4.7.2/socket.io.min.js"></script>
    <style>
        :root {
            --bg-base: #080b11;
            --bg-surface: rgba(17, 24, 39, 0.7);
            --bg-surface-hover: rgba(31, 41, 55, 0.8);
            --primary: #8b5cf6;
            --primary-glow: rgba(139, 92, 246, 0.35);
            --accent: #06b6d4;
            --accent-glow: rgba(6, 182, 212, 0.35);
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --border-color: rgba(255, 255, 255, 0.08);
            --success: #10b981;
            --error: #ef4444;
            --warning: #f59e0b;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', sans-serif;
            scrollbar-width: thin;
            scrollbar-color: var(--primary) var(--bg-base);
        }

        body {
            background-color: var(--bg-base);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(139, 92, 246, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(6, 182, 212, 0.12) 0%, transparent 40%);
            background-attachment: fixed;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.5rem 2.5rem;
            border-bottom: 1px solid var(--border-color);
            background: rgba(8, 11, 17, 0.8);
            backdrop-filter: blur(12px);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo-section {
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .logo-icon {
            width: 2.2rem;
            height: 2.2rem;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1.2rem;
            box-shadow: 0 0 15px var(--primary-glow);
        }

        .logo-text {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(to right, #ffffff, #a78bfa);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 0.5px;
        }

        .status-badge {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: var(--success);
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background-color: var(--success);
            border-radius: 50%;
            box-shadow: 0 0 8px var(--success);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.9); opacity: 0.6; }
            50% { transform: scale(1.1); opacity: 1; box-shadow: 0 0 12px var(--success); }
            100% { transform: scale(0.9); opacity: 0.6; }
        }

        main {
            flex: 1;
            padding: 2rem 2.5rem;
            max-width: 1600px;
            width: 100%;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
        }

        /* Stats Cards */
        .card-stat {
            grid-column: span 1;
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 1.5rem;
            backdrop-filter: blur(8px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            overflow: hidden;
        }

        .card-stat::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--accent));
            opacity: 0;
            transition: opacity 0.3s;
        }

        .card-stat:hover {
            transform: translateY(-4px);
            border-color: rgba(139, 92, 246, 0.3);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3), 0 0 15px rgba(139, 92, 246, 0.05);
        }

        .card-stat:hover::before {
            opacity: 1;
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--text-muted);
            font-size: 0.9rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-value {
            font-size: 2.2rem;
            font-weight: 800;
            margin-top: 0.8rem;
            background: linear-gradient(to right, #ffffff, #e5e7eb);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stat-footer {
            margin-top: 0.8rem;
            font-size: 0.85rem;
            color: var(--accent);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        /* Large Sections */
        .chart-container {
            grid-column: span 3;
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 1.5rem;
            backdrop-filter: blur(8px);
            min-height: 350px;
        }

        .panel-control {
            grid-column: span 1;
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 1.5rem;
            backdrop-filter: blur(8px);
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
            border-left: 3px solid var(--primary);
            padding-left: 0.8rem;
        }

        .recent-actions {
            grid-column: span 2;
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 1.5rem;
            backdrop-filter: blur(8px);
            max-height: 400px;
            overflow-y: auto;
        }

        .live-leaderboard {
            grid-column: span 2;
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 1.5rem;
            backdrop-filter: blur(8px);
            max-height: 400px;
            overflow-y: auto;
        }

        /* Forms and Buttons */
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 600;
        }

        select, input {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 0.7rem 1rem;
            color: var(--text-main);
            outline: none;
            font-size: 0.95rem;
            transition: all 0.2s;
        }

        select:focus, input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 10px var(--primary-glow);
            background: rgba(255, 255, 255, 0.08);
        }

        .btn-action {
            background: linear-gradient(135deg, var(--primary), #7c3aed);
            border: none;
            color: white;
            padding: 0.8rem 1.5rem;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px var(--primary-glow);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            text-transform: uppercase;
            font-size: 0.85rem;
            letter-spacing: 0.5px;
        }

        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.5);
            filter: brightness(1.1);
        }

        .btn-action:active {
            transform: translateY(0);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            color: var(--text-main);
            box-shadow: none;
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--accent);
            box-shadow: 0 4px 15px var(--accent-glow);
        }

        /* List Items styling */
        .list-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.9rem 1rem;
            border-bottom: 1px solid var(--border-color);
            transition: background 0.2s;
            border-radius: 8px;
        }

        .list-item:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .list-item:last-child {
            border-bottom: none;
        }

        .item-info {
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .item-avatar {
            width: 2.2rem;
            height: 2.2rem;
            border-radius: 50%;
            background: var(--border-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            border: 1.5px solid var(--primary);
            color: var(--primary);
            overflow: hidden;
            font-size: 0.9rem;
        }

        .item-name {
            font-weight: 600;
            font-size: 0.95rem;
        }

        .item-sub {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 0.1rem;
        }

        .item-metric {
            text-align: right;
            font-weight: 800;
            font-size: 1.05rem;
            color: var(--accent);
        }

        .toast {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            background: rgba(17, 24, 39, 0.95);
            border: 1px solid var(--primary);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px var(--primary-glow);
            padding: 1rem 1.5rem;
            border-radius: 12px;
            color: var(--text-main);
            z-index: 1000;
            transform: translateY(150%);
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .toast.show {
            transform: translateY(0);
        }

        .toast-success { border-color: var(--success); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(16, 185, 129, 0.2); }
        .toast-error { border-color: var(--error); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(239, 68, 68, 0.2); }

        /* Responsive Layout adjustment */
        @media(max-width: 1200px) {
            main {
                grid-template-columns: repeat(2, 1fr);
            }
            .chart-container { grid-column: span 2; }
            .panel-control { grid-column: span 2; }
        }

        @media(max-width: 768px) {
            main {
                grid-template-columns: 1fr;
                padding: 1rem;
            }
            .card-stat, .chart-container, .panel-control, .recent-actions, .live-leaderboard {
                grid-column: span 1;
            }
            header {
                padding: 1rem;
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="logo-section">
            <div class="logo-icon">S</div>
            <div class="logo-text">Stepify Admin Console</div>
        </div>
        <div class="status-badge">
            <div class="status-dot"></div>
            <span>LIVE ATTACK SHIELD ACTIVE</span>
        </div>
    </header>

    <main>
        <!-- Stat Cards -->
        <div class="card-stat">
            <div class="stat-header">
                <span>Total Registered Users</span>
                <span style="color: var(--primary);">👤</span>
            </div>
            <div class="stat-value" id="val-users">--</div>
            <div class="stat-footer">✓ Database connection active</div>
        </div>

        <div class="card-stat">
            <div class="stat-header">
                <span>Total Steps Tracked</span>
                <span style="color: var(--accent);">👟</span>
            </div>
            <div class="stat-value" id="val-steps">--</div>
            <div class="stat-footer">⚡ Real-time ledger synced</div>
        </div>

        <div class="card-stat">
            <div class="stat-header">
                <span>Total Coins Awarded</span>
                <span style="color: var(--warning);">🪙</span>
            </div>
            <div class="stat-value" id="val-coins">--</div>
            <div class="stat-footer">💎 Anti-infinite exploit locked</div>
        </div>

        <div class="card-stat">
            <div class="stat-header">
                <span>Replay Attacks Prevented</span>
                <span style="color: var(--error);">🛡️</span>
            </div>
            <div class="stat-value" id="val-replays">0</div>
            <div class="stat-footer" style="color: var(--success);">✓ 100% Cryptographic Security</div>
        </div>

        <!-- Chart Section -->
        <div class="chart-container">
            <div class="section-title">📉 30-Day Step Activity Stream</div>
            <canvas id="activityChart" style="max-height: 300px; width: 100%;"></canvas>
        </div>

        <!-- Controls Section -->
        <div class="panel-control">
            <div class="section-title">⚙️ Exploit Simulation Controls</div>
            
            <div class="form-group">
                <label for="select-user">Target Test User</label>
                <select id="select-user">
                    <option value="">Loading users...</option>
                </select>
            </div>

            <div class="form-group">
                <label for="input-steps">Mock Step Count to Sync</label>
                <input type="number" id="input-steps" value="12000" min="0">
            </div>

            <div class="form-group">
                <label for="select-source">Source Attestation Provider</label>
                <select id="select-source">
                    <option value="google_fit">Google Fit (Attested)</option>
                    <option value="apple_health">Apple Health (Attested)</option>
                    <option value="manual">Manual Log</option>
                </select>
            </div>

            <button class="btn-action" id="btn-sync">⚡ Sync Mock Steps</button>
            <button class="btn-action btn-secondary" id="btn-reset-nonces">🔄 Reset Replay Nonces</button>
        </div>

        <!-- Recent sync logs -->
        <div class="recent-actions">
            <div class="section-title">⚡ Live Sync & Audit Log</div>
            <div id="recent-logs-list" style="margin-top: 1rem; display: flex; flex-direction: column; gap: 0.5rem;">
                <div class="list-item" style="color: var(--text-muted);">No recent logs. Sync steps to stream audit records.</div>
            </div>
        </div>

        <!-- Live Leaderboard updates -->
        <div class="live-leaderboard">
            <div class="section-title">🏆 WS Real-Time Leaderboards</div>
            <div id="leaderboard-list" style="margin-top: 1rem; display: flex; flex-direction: column; gap: 0.5rem;">
                <div class="list-item" style="color: var(--text-muted);">Waiting for corporate wellness activities...</div>
            </div>
        </div>
    </main>

    <div class="toast" id="toast">
        <span id="toast-icon">✨</span>
        <span id="toast-text">Action completed successfully.</span>
    </div>

    <script>
        // Global State
        let chart = null;
        let replaysBlockCount = 0;

        // Toast Helper
        function showToast(text, type = 'success') {
            const toast = document.getElementById('toast');
            const icon = document.getElementById('toast-icon');
            const msg = document.getElementById('toast-text');
            
            toast.className = 'toast';
            if (type === 'success') {
                toast.classList.add('toast-success');
                icon.textContent = '✅';
            } else {
                toast.classList.add('toast-error');
                icon.textContent = '❌';
            }
            
            msg.textContent = text;
            toast.classList.add('show');
            
            setTimeout(() => {
                toast.classList.remove('show');
            }, 3000);
        }

        // Fetch Metrics
        async function fetchMetrics() {
            try {
                const res = await fetch('/admin/api/metrics');
                const data = await res.json();
                
                document.getElementById('val-users').textContent = data.usersCount;
                document.getElementById('val-steps').textContent = data.stepsSum.toLocaleString() + ' steps';
                document.getElementById('val-coins').textContent = data.coinsSum.toLocaleString() + ' coins';
                
                // Update User selection
                const select = document.getElementById('select-user');
                const prevVal = select.value;
                select.innerHTML = '';
                
                if (data.users.length === 0) {
                    select.innerHTML = '<option value="">No users in database</option>';
                } else {
                    data.users.forEach(user => {
                        const opt = document.createElement('option');
                        opt.value = user.id;
                        opt.textContent = \`\${user.name || 'Unnamed User'} (\${user.phone || user.email || user.id.slice(0,8)})\`;
                        select.appendChild(opt);
                    });
                    if (prevVal && [...select.options].some(o => o.value === prevVal)) {
                        select.value = prevVal;
                    }
                }

                // Update Sync Logs
                const logList = document.getElementById('recent-logs-list');
                logList.innerHTML = '';
                
                if (data.recentTransactions.length === 0) {
                    logList.innerHTML = '<div class="list-item" style="color: var(--text-muted);">No recent step sync audits.</div>';
                } else {
                    data.recentTransactions.forEach(tx => {
                        const item = document.createElement('div');
                        item.className = 'list-item';
                        item.innerHTML = \`
                            <div class="item-info">
                                <div class="item-avatar">\${(tx.user.name || 'U')[0].toUpperCase()}</div>
                                <div>
                                    <div class="item-name">\${tx.user.name || 'User'}</div>
                                    <div class="item-sub">\${tx.description || 'Synced steps'}</div>
                                </div>
                            </div>
                            <div class="item-metric">+\${tx.points} 🪙</div>
                        \`;
                        logList.appendChild(item);
                    });
                }

                // Render Chart
                renderChart(data.chartData);

            } catch (err) {
                console.error('Error fetching admin metrics:', err);
            }
        }

        // Render Chart Helper
        function renderChart(chartData) {
            const ctx = document.getElementById('activityChart').getContext('2d');
            
            const labels = chartData.map(d => d.date);
            const steps = chartData.map(d => d.steps);
            
            if (chart) {
                chart.data.labels = labels;
                chart.data.datasets[0].data = steps;
                chart.update();
                return;
            }

            chart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Total Daily Steps Synced',
                        data: steps,
                        borderColor: '#8b5cf6',
                        backgroundColor: 'rgba(139, 92, 246, 0.15)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#06b6d4',
                        pointBorderColor: '#fff',
                        pointHoverRadius: 7
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: {
                            grid: { color: 'rgba(255, 255, 255, 0.05)' },
                            ticks: { color: '#9ca3af' }
                        },
                        x: {
                            grid: { display: false },
                            ticks: { color: '#9ca3af' }
                        }
                    }
                }
            });
        }

        // Setup Socket.IO WebSockets live leaderboards
        function setupWebSockets() {
            const socket = io('/leaderboard', {
                transports: ['websocket', 'polling']
            });

            socket.on('connect', () => {
                console.log('🔴 Connected to Leaderboard WebSocket namespace');
            });

            // Listen to any corporate updates (dynamic listener helper)
            socket.on('global_update', (data) => {
                updateLeaderboardUI(data);
            });

            // Since we broadcast specifically per-company, we can also capture broadcasts
            // using socket.onAny in Socket.io client to display live rankings dynamically!
            socket.onAny((event, data) => {
                if (event.startsWith('update:')) {
                    console.log('📢 Real-time WS leaderboard payload received:', data);
                    updateLeaderboardUI(data);
                }
            });
        }

        function updateLeaderboardUI(leaderboardData) {
            const board = document.getElementById('leaderboard-list');
            board.innerHTML = '';
            
            if (!leaderboardData || leaderboardData.length === 0) {
                board.innerHTML = '<div class="list-item" style="color: var(--text-muted);">Waiting for corporate wellness activities...</div>';
                return;
            }

            leaderboardData.forEach((member, index) => {
                const item = document.createElement('div');
                item.className = 'list-item';
                const medal = index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : \`#\${index + 1}\`;
                item.innerHTML = \`
                    <div class="item-info">
                        <div style="font-size: 1.2rem; font-weight: 800; min-width: 2rem;">\${medal}</div>
                        <div class="item-avatar" style="border-color: var(--accent);">\${(member.user?.name || 'E')[0]}</div>
                        <div>
                            <div class="item-name">\${member.user?.name || 'Employee'}</div>
                            <div class="item-sub">Wellness Participant</div>
                        </div>
                    </div>
                    <div class="item-metric" style="color: var(--primary);">\${member.totalSteps.toLocaleString()} steps</div>
                \`;
                board.appendChild(item);
            });
            showToast('📢 Real-time Leaderboard WS update received!', 'success');
        }

        // Trigger Mock Sync Steps
        document.getElementById('btn-sync').addEventListener('click', async () => {
            const userId = document.getElementById('select-user').value;
            const stepCount = parseInt(document.getElementById('input-steps').value);
            const source = document.getElementById('select-source').value;

            if (!userId) {
                showToast('Please select a test user first.', 'error');
                return;
            }

            try {
                const res = await fetch('/admin/api/mock/steps', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ userId, stepCount, source })
                });
                
                const data = await res.json();
                
                if (res.ok) {
                    showToast(\`Successfully synced \${stepCount.toLocaleString()} steps!\`, 'success');
                    fetchMetrics();
                } else {
                    // Exploit protection works!
                    if (data.message.includes('replay') || data.message.includes('exceeds') || data.message.includes('drift')) {
                        replaysBlockCount++;
                        document.getElementById('val-replays').textContent = replaysBlockCount;
                        showToast(\`🛡️ ANTI-CHEAT BLOCKED: \${data.message}\`, 'error');
                    } else {
                        showToast(data.message || 'Failed to sync steps.', 'error');
                    }
                }
            } catch (err) {
                showToast('API Communication error.', 'error');
            }
        });

        // Reset Nonces
        document.getElementById('btn-reset-nonces').addEventListener('click', async () => {
            try {
                const res = await fetch('/admin/api/mock/reset-nonces', { method: 'POST' });
                if (res.ok) {
                    showToast('Redis nonces successfully flushed.', 'success');
                } else {
                    showToast('Failed to reset nonces.', 'error');
                }
            } catch (err) {
                showToast('Communication error.', 'error');
            }
        });

        // Initialize
        fetchMetrics();
        setupWebSockets();
        setInterval(fetchMetrics, 10000); // Polling refresh every 10 seconds for metrics
    </script>
</body>
</html>
        `;
    }

    @Get('api/metrics')
    async getMetrics() {
        const usersCount = await this.prisma.user.count();

        const totalSteps = await this.prisma.step.aggregate({
            _sum: { stepCount: true },
        });

        const totalCoins = await this.prisma.wallet.aggregate({
            _sum: { balance: true },
        });

        const users = await this.prisma.user.findMany({
            take: 15,
            orderBy: { createdAt: 'desc' },
            select: { id: true, name: true, phone: true, email: true },
        });

        const recentTransactions = await this.prisma.transaction.findMany({
            where: { type: 'STEPS' },
            take: 6,
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: { name: true, phone: true, email: true },
                },
            },
        });

        // 30-Day aggregate steps for activity chart
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        const stepsData = await this.prisma.step.groupBy({
            by: ['date'],
            where: {
                date: { gte: thirtyDaysAgo },
            },
            _sum: { stepCount: true },
            orderBy: { date: 'asc' },
        });

        const chartData = stepsData.map(d => {
            const dateStr = d.date.toISOString().split('T')[0];
            return {
                date: dateStr,
                steps: d._sum.stepCount || 0,
            };
        });

        return {
            usersCount,
            stepsSum: totalSteps._sum.stepCount || 0,
            coinsSum: totalCoins._sum.balance || 0,
            users,
            recentTransactions,
            chartData,
        };
    }

    @Post('api/mock/steps')
    async mockSyncSteps(
        @Body() body: { userId: string; stepCount: number; source: string },
    ) {
        // Build cryptographic sync payload mimicking the hardened Flutter SyncStepsDto contract
        const nonce = `mock-nonce-${Math.random().toString(36).substring(2, 11)}-${Date.now()}`;
        const timestamp = Date.now();
        const dateStr = new Date().toISOString().split('T')[0];

        // Ensure the admin mock simulation device is registered and active in DB for this user
        const mockDeviceIdentifier = 'admin-attested-device-uuid';
        const existingDevice = await this.prisma.device.findFirst({
            where: {
                userId: body.userId,
                identifier: mockDeviceIdentifier,
                isActive: true,
            },
        });

        if (!existingDevice) {
            await this.prisma.device.create({
                data: {
                    userId: body.userId,
                    name: 'Admin Attestation Simulator',
                    type: 'PHONE',
                    identifier: mockDeviceIdentifier,
                    isActive: true,
                },
            });
        }

        // Call the service under syncSteps to pass through ALL anti-cheat validations,
        // thereby showing the anti-cheat shield working actively in real-time!
        return this.stepsService.syncSteps(body.userId, {
            deviceIdentifier: mockDeviceIdentifier,
            date: dateStr,
            stepCount: body.stepCount,
            source: body.source,
            nonce: nonce,
            timestamp: timestamp,
            integrity: {
                isJailBroken: false,
                isRealDevice: true,
                isMockLocation: false,
            },
        });
    }

    @Post('api/mock/reset-nonces')
    async resetNonces() {
        // Flush all keys matching nonce:* to ease testing
        const client = this.redisService.getClient();
        if (client.status === 'ready') {
            const keys = await client.keys('nonce:*');
            if (keys.length > 0) {
                await client.del(...keys);
            }
            return { status: 'success', flushedCount: keys.length };
        }
        return { status: 'mock_in_memory_reset', message: 'No Redis connected. Local memory nonces automatically recycled.' };
    }
}
