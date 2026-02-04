// Cisterna Patio - Dashboard JavaScript

let updateInterval = null;

// Show/hide sections
function showSection(sectionId) {
    document.querySelectorAll('section').forEach(section => {
        section.style.display = 'none';
    });
    document.getElementById(sectionId).style.display = 'block';

    if (sectionId === 'dashboard') {
        startAutoUpdate();
    } else {
        stopAutoUpdate();
    }

    if (sectionId === 'tankConfig') {
        loadTankConfig();
    }
}

// Update status from device
async function updateStatus() {
    try {
        const response = await fetch('/api/status');
        const data = await response.json();

        // Update level display
        if (data.level) {
            document.getElementById('levelPercent').textContent =
                Math.round(data.level.percent) + '%';
            document.getElementById('levelLiters').textContent =
                Math.round(data.level.liters) + ' Litros';

            const alertBadge = document.getElementById('levelAlert');
            alertBadge.textContent = data.level.alert || 'NORMAL';
            alertBadge.className = 'alert-badge ' +
                (data.level.alert || 'normal').toLowerCase();
        }

        // Update pump status
        if (data.pump1) {
            document.getElementById('pump1Status').textContent =
                data.pump1.running ? '🟢 LIGADA' : '⚫ DESLIGADA';
        }
        if (data.pump2) {
            document.getElementById('pump2Status').textContent =
                data.pump2.running ? '🟢 LIGADA' : '⚫ DESLIGADA';
        }

        // Update connection status
        updateConnectionStatus(data.wifi_connected, data.mqtt_connected);

    } catch (error) {
        console.error('Erro ao atualizar status:', error);
    }
}

function updateConnectionStatus(wifi, mqtt) {
    const wifiStatus = document.getElementById('wifiStatus');
    const mqttStatus = document.getElementById('mqttStatus');

    wifiStatus.className = wifi ? 'connected' : '';
    mqttStatus.className = mqtt ? 'connected' : '';
}

function startAutoUpdate() {
    if (updateInterval) return;
    updateStatus();
    updateInterval = setInterval(updateStatus, 2000);
}

function stopAutoUpdate() {
    if (updateInterval) {
        clearInterval(updateInterval);
        updateInterval = null;
    }
}

// Tank configuration
function updateTankFields() {
    const shape = document.getElementById('tankShape').value;
    const rectFields = document.getElementById('rectangularFields');
    const cylFields = document.getElementById('cylindricalFields');

    if (shape === 'rectangular') {
        rectFields.style.display = 'block';
        cylFields.style.display = 'none';
        document.getElementById('height').required = true;
        document.getElementById('width').required = true;
        document.getElementById('depth').required = true;
        document.getElementById('heightCyl').required = false;
        document.getElementById('diameterTop').required = false;
        document.getElementById('diameterBottom').required = false;
    } else {
        rectFields.style.display = 'none';
        cylFields.style.display = 'block';
        document.getElementById('height').required = false;
        document.getElementById('width').required = false;
        document.getElementById('depth').required = false;
        document.getElementById('heightCyl').required = true;
        document.getElementById('diameterTop').required = true;
        document.getElementById('diameterBottom').required = true;
    }

    calculateVolume();
}

function calculateVolume() {
    const shape = document.getElementById('tankShape').value;
    let volume = 0;

    if (shape === 'rectangular') {
        const h = parseFloat(document.getElementById('height').value) || 0;
        const w = parseFloat(document.getElementById('width').value) || 0;
        const d = parseFloat(document.getElementById('depth').value) || 0;
        volume = (h * w * d) / 1000; // cm³ to liters
    } else {
        const h = parseFloat(document.getElementById('heightCyl').value) || 0;
        const dt = parseFloat(document.getElementById('diameterTop').value) || 0;
        const db = parseFloat(document.getElementById('diameterBottom').value) || 0;
        const avgD = (dt + db) / 2;
        const r = avgD / 2;
        volume = (Math.PI * r * r * h) / 1000; // cm³ to liters
    }

    document.getElementById('maxVolume').textContent =
        Math.round(volume) + ' L';
}

// Toggle Pump
async function togglePump(pumpIndex) {
    try {
        const response = await fetch('/api/command', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ command: 'toggle', pump: pumpIndex })
        });
        const result = await response.json();
        if (!result.ok) {
            alert('Erro: ' + (result.error || 'Falha ao acionar bomba'));
        } else {
            updateStatus(); // Immediate status refresh
        }
    } catch (error) {
        console.error('Erro ao acionar bomba:', error);
        alert('Erro de comunicação');
    }
}

// Load current tank configuration
async function loadTankConfig() {
    try {
        const response = await fetch('/api/config');
        const config = await response.json();

        if (config.tank) {
            document.getElementById('tankShape').value = config.tank.shape || 'rectangular';
            updateTankFields();

            if (config.tank.shape === 'rectangular') {
                document.getElementById('height').value = config.tank.height || '';
                document.getElementById('width').value = config.tank.width || '';
                document.getElementById('depth').value = config.tank.depth || '';
            } else {
                document.getElementById('heightCyl').value = config.tank.height || '';
                document.getElementById('diameterTop').value = config.tank.diameter_top || '';
                document.getElementById('diameterBottom').value = config.tank.diameter_bottom || '';
            }

            document.getElementById('sensorOffset').value = config.tank.sensor_offset || 5;
            calculateVolume();
        }

        if (config.report_interval) {
            document.getElementById('reportInterval').value = config.report_interval;
        }

        if (config.temperature !== undefined) {
            document.getElementById('temperature').value = config.temperature;
        }
    } catch (error) {
        console.error('Erro ao carregar configuração:', error);
    }
}

// Save tank configuration
document.getElementById('tankForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const shape = document.getElementById('tankShape').value;
    const config = {
        shape: shape,
        sensor_offset: parseFloat(document.getElementById('sensorOffset').value)
    };

    if (shape === 'rectangular') {
        config.height = parseFloat(document.getElementById('height').value);
        config.width = parseFloat(document.getElementById('width').value);
        config.depth = parseFloat(document.getElementById('depth').value);
    } else {
        config.height = parseFloat(document.getElementById('heightCyl').value);
        config.diameter_top = parseFloat(document.getElementById('diameterTop').value);
        config.diameter_bottom = parseFloat(document.getElementById('diameterBottom').value);
    }

    const reportInterval = parseInt(document.getElementById('reportInterval').value);
    const temperature = parseFloat(document.getElementById('temperature').value);

    try {
        const response = await fetch('/api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                tank: config,
                report_interval: reportInterval,
                temperature: temperature
            })
        });

        const result = await response.json();

        if (result.ok) {
            alert('✅ Configuração salva com sucesso!');
            // Reload to ensure all values are applied
            loadTankConfig();
            showSection('dashboard');
        } else {
            alert('❌ Erro ao salvar: ' + (result.error || 'Desconhecido'));
        }
    } catch (error) {
        alert('❌ Erro de comunicação: ' + error.message);
    }
});

// Auto-calculate volume on input change
document.querySelectorAll('input[type="number"]').forEach(input => {
    input.addEventListener('input', calculateVolume);
});

// Initialize
showSection('dashboard');
