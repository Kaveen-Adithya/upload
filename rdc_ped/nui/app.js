// Red Dream City Ped Menu - JavaScript Logic
let pedData = null;
let currentFilter = 'all';
let currentSearch = '';

document.addEventListener('DOMContentLoaded', function() {
    // Listen for messages from Lua
    window.addEventListener('message', function(event) {
        const item = event.data;

        if (item.action === 'openMenu') {
            pedData = item.data;
            initializeMenu();
        }
    });

    // Setup event listeners
    document.getElementById('close-btn').addEventListener('click', closeMenu);
    document.getElementById('reset-btn').addEventListener('click', resetPed);
    document.getElementById('search-input').addEventListener('input', filterPeds);

    // Initial setup
    setupInitialView();
});

function setupInitialView() {
    // Hide the menu initially until data is received
    document.getElementById('ped-menu-container').style.display = 'none';
}

function initializeMenu() {
    // Update user information
    document.getElementById('player-name').textContent = pedData.playerName || 'Unknown';
    document.getElementById('tier-value').textContent = pedData.playerGroup || 'user';

    // Calculate stats
    updateStats();

    // Generate category filters
    generateCategoryFilters();

    // Populate ped list
    populatePedList();

    // Show the menu
    document.getElementById('ped-menu-container').style.display = 'flex';
}

function updateStats() {
    if (!pedData || !pedData.allowedPeds) return;

    const totalPeds = pedData.allowedPeds.length;
    const categories = [...new Set(pedData.allowedPeds.map(ped => ped.category))];
    
    document.getElementById('total-peds-count').textContent = totalPeds;
    document.getElementById('categories-count').textContent = categories.length;
}

function generateCategoryFilters() {
    if (!pedData || !pedData.allowedPeds) return;

    const categories = [...new Set(pedData.allowedPeds.map(ped => ped.category))];
    const container = document.getElementById('category-filters');
    
    container.innerHTML = '';
    
    // Add "All" filter
    const allBtn = document.createElement('button');
    allBtn.className = 'category-btn active';
    allBtn.textContent = 'All';
    allBtn.dataset.category = 'all';
    allBtn.addEventListener('click', function() {
        setActiveCategory(this.dataset.category);
    });
    container.appendChild(allBtn);
    
    // Add category buttons
    categories.forEach(category => {
        const btn = document.createElement('button');
        btn.className = 'category-btn';
        btn.textContent = capitalizeFirstLetter(category);
        btn.dataset.category = category;
        btn.addEventListener('click', function() {
            setActiveCategory(this.dataset.category);
        });
        container.appendChild(btn);
    });
}

function setActiveCategory(category) {
    currentFilter = category;
    
    // Update active class
    document.querySelectorAll('.category-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    const activeBtn = Array.from(document.querySelectorAll('.category-btn')).find(
        btn => btn.dataset.category === category
    );
    
    if (activeBtn) {
        activeBtn.classList.add('active');
    }
    
    // Filter peds
    filterPeds();
}

function populatePedList() {
    if (!pedData || !pedData.allowedPeds) return;

    const container = document.getElementById('ped-list');
    container.innerHTML = '';

    pedData.allowedPeds.forEach(ped => {
        const pedElement = createPedElement(ped);
        container.appendChild(pedElement);
    });
}

function createPedElement(ped) {
    const div = document.createElement('div');
    div.className = 'ped-item';
    div.dataset.category = ped.category;
    div.dataset.search = `${ped.label} ${ped.model} ${ped.description} ${ped.category}`.toLowerCase();

    div.innerHTML = `
        <img src="${ped.image || 'https://via.placeholder.com/280x160/1a1a1a/ffffff?text=No+Image'}" alt="${ped.label}" class="ped-image" onerror="this.src='https://via.placeholder.com/280x160/1a1a1a/ffffff?text=No+Image'">
        <div class="ped-info">
            <div class="ped-title">${ped.label}</div>
            <div class="ped-model">${ped.model}</div>
            <div class="ped-description">${ped.description}</div>
            <div class="ped-meta">
                <span class="ped-category">${capitalizeFirstLetter(ped.category)}</span>
                <span class="ped-gender">${ped.gender ? capitalizeFirstLetter(ped.gender) : 'Any'}</span>
                ${ped.restricted ? `<span class="ped-restricted">Restricted</span>` : ''}
            </div>
            <button class="apply-btn" data-model="${ped.model}">Apply Ped</button>
            ${ped.restricted ? `<div class="restricted-indicator">Requires Tier: ${ped.minTier || 'Unknown'}</div>` : ''}
        </div>
    `;

    // Add event listener to the apply button
    const applyBtn = div.querySelector('.apply-btn');
    applyBtn.addEventListener('click', function() {
        applyPed(ped.model);
    });

    return div;
}

function filterPeds() {
    currentSearch = document.getElementById('search-input').value.toLowerCase();

    const pedItems = document.querySelectorAll('.ped-item');
    
    pedItems.forEach(item => {
        const matchesCategory = currentFilter === 'all' || item.dataset.category === currentFilter;
        const matchesSearch = item.dataset.search.includes(currentSearch);
        
        if (matchesCategory && matchesSearch) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}

function applyPed(model) {
    fetch(`https://${GetParentResourceName()}/applyPed`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ pedModel: model })
    }).then(response => response.json())
    .then(data => {
        if (!data.success) {
            // Handle error if needed
            console.error('Failed to apply ped:', data);
        }
    }).catch(error => {
        console.error('Error applying ped:', error);
    });
}

function resetPed() {
    fetch(`https://${GetParentResourceName()}/resetPed`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json())
    .then(data => {
        if (!data.success) {
            // Handle error if needed
            console.error('Failed to reset ped:', data);
        }
    }).catch(error => {
        console.error('Error resetting ped:', error);
    });
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json())
    .then(data => {
        // Menu closed, nothing to handle here
    }).catch(error => {
        console.error('Error closing menu:', error);
    });
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}