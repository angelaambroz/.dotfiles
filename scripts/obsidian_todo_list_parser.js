// Generate today's daily note filename in the format: discord/2024-Jan-17 (Wednesday).md
function getTodayFileName() {
    const date = new Date();
    const formatter = new Intl.DateTimeFormat('en', {
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        weekday: 'long'
    });
    
    // Convert formatted parts into an object for easy access
    const parts = formatter.formatToParts(date);
    const values = parts.reduce((acc, part) => {
        acc[part.type] = part.value;
        return acc;
    }, {});
    
    return `discord/${values.year}-${values.month}-${values.day} (${values.weekday}).md`;
}

// === GATHER ALL TASKS FROM VARIOUS SOURCES ===

// Get today's file and extract work/personal tasks
const todayFile = getTodayFileName();
const todayPage = dv.page(todayFile);
const todaysWorkTasks = (todayPage?.file?.tasks || []).filter(t => t.text.includes('#work'));
const todaysPersonalTasks = (todayPage?.file?.tasks || []).filter(t => t.text.includes('#personal'));
console.log("Found work tasks:", todaysWorkTasks.length);
console.log("Found personal tasks:", todaysPersonalTasks.length);

// Get waiting tasks from the backlog
const backlogFile = 'discord/BACKLOG.md';
const backlogPage = dv.page(backlogFile);
const waitingTasks = (backlogPage?.file?.tasks || []).filter(t => t.text.includes('#waiting'));
console.log("Found waiting tasks:", waitingTasks.length);

// Get tasks due in the next 7 days
const today = new Date();
const sevenDaysLater = new Date();
sevenDaysLater.setDate(today.getDate() + 7);

const dueSoonTasks = (backlogPage?.file?.tasks || []).filter(t => {
    // Look for due dates in format 📅 YYYY-MM-DD
    const dueDateMatch = t.text.match(/📅\s*(\d{4}-\d{2}-\d{2})/);
    if (!dueDateMatch) return false;
    
    const dueDate = new Date(dueDateMatch[1]);
    return dueDate <= sevenDaysLater && !t.completed;
});
console.log("Found due soon tasks:", dueSoonTasks.length);

// === TASK PARSING HELPER ===

// Parse a task to extract time estimates, due dates, and clean text
function parseTask(task) {
    // Extract time estimate (e.g., "30m" or "2h")
    const timeMatch = task.text.match(/(\d+)([mh])/);
    const timeEst = timeMatch ? parseInt(timeMatch[1]) : null;
    const timeUnit = timeMatch ? timeMatch[2] : null;
    const mins = timeUnit === 'h' ? timeEst * 60 : timeEst;
    
    // Extract due date (format: 📅 YYYY-MM-DD)
    const dueDateMatch = task.text.match(/📅\s*(\d{4}-\d{2}-\d{2})/);
    const dueDate = dueDateMatch ? new Date(dueDateMatch[1]) : null;
    
    // Check if task is waiting on something
    const isWaiting = task.text.includes('#waiting');
    
    // Clean up the task text by removing time and date info
    const cleanText = task.text
        .replace(/⏲ \d+[mh]/, '')
        .replace(/📅\s*\d{4}-\d{2}-\d{2}/, '')
        .trim();
    
    return {
        text: cleanText,
        mins: mins,
        dueDate: dueDate,
        isWaiting: isWaiting,
        completed: task.completed,
        willNotDo: task.status === '-'
    };
}

// === PARSE ALL TASKS ===

const parsedTodaysWorkTasks = todaysWorkTasks.map(parseTask);
const parsedTodaysPersonalTasks = todaysPersonalTasks.map(parseTask);
const parsedWaitingTasks = waitingTasks.map(parseTask);
const parsedDueSoonTasks = dueSoonTasks.map(parseTask);

// === CALCULATE TIME ESTIMATES ===

// Helper function to filter for active (non-waiting, non-completed) tasks
const getActiveTasks = (tasks) => tasks.filter(t => !t.isWaiting && !t.completed && !t.willNotDo);

// Calculate total time for work and personal tasks
const activeWorkTasks = getActiveTasks(parsedTodaysWorkTasks);
const activePersonalTasks = getActiveTasks(parsedTodaysPersonalTasks);

const totalWorkMins = activeWorkTasks.reduce((sum, t) => sum + (t.mins || 0), 0);
const totalPersonalMins = activePersonalTasks.reduce((sum, t) => sum + (t.mins || 0), 0);

// === DISPLAY RESULTS ===

// Helper function to format minutes into hours and minutes
const formatTime = (totalMins) => {
    const hours = Math.floor(totalMins / 60);
    const mins = totalMins % 60;
    return `${hours}h ${mins}m`;
};

// Display time summaries
dv.header(1, `🧠 Work: ${formatTime(totalWorkMins)}`);
dv.header(1, `🧠 Personal: ${formatTime(totalPersonalMins)}`);

// Show tasks due soon (sorted by due date)
dv.header(2, "📅 Due Soon");
const upcomingTasks = parsedDueSoonTasks
    .filter(t => t.dueDate && !t.completed && !t.willNotDo)
    .sort((a, b) => a.dueDate - b.dueDate)
    .map(t => [
        t.text,
        t.dueDate.toISOString().split('T')[0], // Format as YYYY-MM-DD
        t.mins ? formatTime(t.mins) : ""
    ]);

dv.table(["Task", "Due Date", "Time Est."], upcomingTasks);

// Show tasks we're waiting on others for
dv.header(2, "⏳ Waiting On");
const waitingTaskTexts = parsedWaitingTasks
    .filter(t => t.isWaiting && !t.completed)
    .map(t => t.text);

dv.list(waitingTaskTexts);
