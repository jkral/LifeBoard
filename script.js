document.addEventListener('DOMContentLoaded', () => {

    // =========================================================================
    // STATE MANAGEMENT
    // =========================================================================

    // Load data from Local Storage or set default values
    let categoryData = JSON.parse(localStorage.getItem('lifeBoardCategoryData')) || {
        health: { mental: 5, physical: 5, spiritual: 5, active: true },
        personal: { partner: 5, family: 5, social: 5, active: true },
        professional: { work: 5, growth: 5, passion: 5, active: true }
    };

    let goals = JSON.parse(localStorage.getItem('lifeBoardGoals')) || [];
    let currentEditId = null; // null for adding, stores ID for editing

    // =========================================================================
    // DOM ELEMENT REFERENCES
    // =========================================================================
    const totalScoreSpan = document.getElementById('total-score');
    const categoriesContainer = document.querySelectorAll('.category');
    const addGoalBtn = document.getElementById('add-goal-btn');
    const kanbanBoard = document.querySelector('.kanban-board'); // Parent for event delegation

    // Kanban Columns
    const todoCardsContainer = document.getElementById('todo-cards');
    const inprogressCardsContainer = document.getElementById('inprogress-cards');
    const doneCardsContainer = document.getElementById('done-cards');

    // Goal Modal Elements
    const goalModal = document.getElementById('goal-modal');
    const modalTitle = document.getElementById('modal-title');
    const closeModalBtn = goalModal.querySelector('.close-btn');
    const saveGoalBtn = document.getElementById('save-goal-btn');
    const goalTextInput = document.getElementById('goal-text');


    // =========================================================================
    // DATA PERSISTENCE (LOCAL STORAGE)
    // =========================================================================

    const saveCategoryData = () => {
        localStorage.setItem('lifeBoardCategoryData', JSON.stringify(categoryData));
    };

    const saveGoals = () => {
        localStorage.setItem('lifeBoardGoals', JSON.stringify(goals));
    };

    // =========================================================================
    // CORE LOGIC & CALCULATIONS
    // =========================================================================

    const calculateCategoryScore = (categoryName) => {
        const category = categoryData[categoryName];
        if (!category || !category.active) return 0;

        const subcategories = Object.keys(category).filter(key => typeof category[key] === 'number');
        if (subcategories.length === 0) return 0;

        const sum = subcategories.reduce((acc, key) => acc + category[key], 0);
        return sum / subcategories.length;
    };

    const addGoal = (text) => {
        const newGoal = {
            id: Date.now().toString(), // Simple unique ID
            text: text,
            status: 'todo'
        };
        goals.push(newGoal);
    };

    const updateGoal = (id, newText) => {
        const goal = goals.find(g => g.id === id);
        if (goal) {
            goal.text = newText;
        }
    };

    const deleteGoal = (id) => {
        if (confirm('Are you sure you want to delete this goal?')) {
            goals = goals.filter(goal => goal.id !== id);
            saveGoals();
            renderGoals();
        }
    };
    
    const updateGoalStatus = (id, newStatus) => {
        const goal = goals.find(g => g.id === id);
        if(goal) {
            goal.status = newStatus;
            saveGoals();
        }
    };

    // =========================================================================
    // UI RENDERING & UPDATES
    // =========================================================================

    const updateScores = () => {
        let totalSum = 0;
        let activeCategoriesCount = 0;

        categoriesContainer.forEach(categoryEl => {
            const categoryName = categoryEl.id;
            const categoryScoreSpan = categoryEl.querySelector('.category-score');
            const isActiveCheckbox = categoryEl.querySelector(`#${categoryName}-active`);

            categoryData[categoryName].active = isActiveCheckbox.checked;

            if (isActiveCheckbox.checked) {
                categoryEl.classList.remove('inactive');
                const score = calculateCategoryScore(categoryName);
                categoryScoreSpan.textContent = score.toFixed(1);
                totalSum += score;
                activeCategoriesCount++;
            } else {
                categoryEl.classList.add('inactive');
                categoryScoreSpan.textContent = 'N/A';
            }
        });

        totalScoreSpan.textContent = activeCategoriesCount > 0 ? (totalSum / activeCategoriesCount).toFixed(1) : "0.0";
        saveCategoryData();
    };

    const initializeCategories = () => {
        for (const categoryName in categoryData) {
            const category = categoryData[categoryName];
            const categoryEl = document.getElementById(categoryName);
            if (!categoryEl) continue;

            const isActiveCheckbox = categoryEl.querySelector(`#${categoryName}-active`);
            isActiveCheckbox.checked = category.active;

            for (const subcategoryName in category) {
                if (typeof category[subcategoryName] === 'number') {
                    const slider = categoryEl.querySelector(`#${subcategoryName}-slider`);
                    const valueSpan = categoryEl.querySelector(`#${subcategoryName}-value`);

                    if (slider && valueSpan) {
                        // Part 1: Format the initial value on page load
                        const initialValue = category[subcategoryName];
                        slider.value = initialValue;
                        valueSpan.textContent = initialValue.toFixed(1); // CHANGED
                    
                        // Part 2: Format the value every time the slider moves
                        slider.addEventListener('input', (e) => {
                            const newValue = parseFloat(e.target.value);
                            valueSpan.textContent = newValue.toFixed(1); // CHANGED
                            categoryData[categoryName][subcategoryName] = newValue;
                            updateScores();
                        });
                    }
                }
            }
            // Add listener for checkbox changes
            isActiveCheckbox.addEventListener('change', updateScores);
        }
        updateScores(); // Initial calculation
    };

    const renderGoals = () => {
        // Clear existing cards
        todoCardsContainer.innerHTML = '';
        inprogressCardsContainer.innerHTML = '';
        doneCardsContainer.innerHTML = '';

        goals.forEach(goal => {
            const goalCard = document.createElement('div');
            goalCard.className = 'goal-card';
            goalCard.setAttribute('draggable', true);
            goalCard.dataset.id = goal.id;

            goalCard.innerHTML = `
            <i class="fas fa-hand-paper drag-handle" aria-label="Drag to reorder"></i>
            <span class="goal-text">${goal.text}</span>
            <div class="actions">
                <button class="edit-goal-btn" aria-label="Edit Goal"><i class="fas fa-pencil-alt"></i></button>
                <button class="delete-goal-btn" aria-label="Delete Goal"><i class="fas fa-trash"></i></button>
            </div>
        `;

            // Place card in the correct column
            if (goal.status === 'inprogress') {
                inprogressCardsContainer.appendChild(goalCard);
            } else if (goal.status === 'done') {
                doneCardsContainer.appendChild(goalCard);
            } else { // 'todo' or any other status
                todoCardsContainer.appendChild(goalCard);
            }
        });
    };

    // =========================================================================
    // GOAL MODAL HANDLING
    // =========================================================================

    const openModalForEdit = (id) => {
        const goal = goals.find(g => g.id === id);
        if (!goal) return;

        currentEditId = id;
        modalTitle.textContent = 'Edit Goal';
        goalTextInput.value = goal.text;
        goalModal.style.display = 'flex';
        goalTextInput.focus();
    };

    const openModalForAdd = () => {
        currentEditId = null;
        modalTitle.textContent = 'Add New Goal';
        goalTextInput.value = '';
        goalModal.style.display = 'flex';
        goalTextInput.focus();
    };

    const closeModal = () => {
        goalModal.style.display = 'none';
        currentEditId = null;
        goalTextInput.value = '';
    };

    const handleSaveGoal = () => {
        const goalText = goalTextInput.value.trim();
        if (!goalText) {
            alert('Please enter a goal description.');
            return;
        }

        if (currentEditId) {
            // We are editing an existing goal
            updateGoal(currentEditId, goalText);
        } else {
            // We are adding a new goal
            addGoal(goalText);
        }

        saveGoals();
        renderGoals();
        closeModal();
    };

    // =========================================================================
    // EVENT HANDLERS & LISTENERS
    // =========================================================================

    const setupEventListeners = () => {
        // Modal Buttons
        addGoalBtn.addEventListener('click', openModalForAdd);
        closeModalBtn.addEventListener('click', closeModal);
        saveGoalBtn.addEventListener('click', handleSaveGoal);

        // Close modal if clicking outside of it
        window.addEventListener('click', (e) => {
            if (e.target === goalModal) {
                closeModal();
            }
        });
        
        // Handle Enter key in modal
        goalTextInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                handleSaveGoal();
            }
        });

        // --- Event Delegation for Dynamic Content ---
        // A single listener on the board handles clicks for all current and future goal cards.
        kanbanBoard.addEventListener('click', (e) => {
            const editBtn = e.target.closest('.edit-goal-btn');
            const deleteBtn = e.target.closest('.delete-goal-btn');

            if (editBtn) {
                const goalCard = editBtn.closest('.goal-card');
                openModalForEdit(goalCard.dataset.id);
            } else if (deleteBtn) {
                const goalCard = deleteBtn.closest('.goal-card');
                deleteGoal(goalCard.dataset.id);
            }
        });
    };

    const initializeSortableLists = () => {
        const cardContainers = document.querySelectorAll('.goal-cards');
    
        cardContainers.forEach(container => {
            new Sortable(container, {
                group: 'goals',
                animation: 150,
                ghostClass: 'sortable-ghost',
    
                // --- THIS IS THE KEY ---
                // Tell SortableJS that only elements with the class '.drag-handle'
                // can be used to initiate a drag.
                handle: '.drag-handle',
    
                // We no longer need the delay options because the handle provides
                // explicit intent. This improves the user experience.
    
                onAdd: function (evt) {
                    const card = evt.item;
                    const newContainer = evt.to;
                    const goalId = card.dataset.id;
                    const newStatus = newContainer.id.replace('-cards', '');
                    updateGoalStatus(goalId, newStatus);
                }
            });
        });
    };

    // =========================================================================
    // INITIALIZATION
    // =========================================================================

    const init = () => {
        initializeCategories();
        renderGoals();
        setupEventListeners();
        initializeSortableLists(); 
    };

    // Run the application
    init();
});


