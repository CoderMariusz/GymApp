# Story 2.8: Daily Plan Manual Adjustment

**Epic:** Epic 2 - Life Coach MVP
**Priority:** P1 | **Status:** drafted | **Effort:** 2 SP

---

## User Story
**As a** user with a generated daily plan
**I want** to manually adjust or skip suggestions
**So that** I have flexibility when my day changes

---

## Acceptance Criteria
1. ✅ Tap plan item to edit
2. ✅ Change task description
3. ✅ Change task time
4. ✅ Delete task (swipe left gesture)
5. ✅ Add custom task to plan
6. ✅ Reorder tasks (drag & drop)
7. ✅ Changes save immediately (optimistic UI)
8. ✅ AI learns from adjustments (future plans adapt)

**FRs:** FR9

---

## Technical Implementation

### Edit Modal
```dart
class EditTaskModal extends StatelessWidget {
  final Task task;

  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          TextField(
            initialValue: task.title,
            onChanged: (v) => task.title = v,
          ),
          TimePicker(
            initialTime: task.time,
            onChanged: (v) => task.time = v,
          ),
          ElevatedButton(
            onPressed: () => saveTask(task),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

### Drag & Drop Reorder
```dart
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
      savePlanOrder(tasks);
    });
  },
  children: tasks.map((t) => TaskTile(t)).toList(),
)
```

---

## Dependencies
**Prerequisites:** Story 2.2 (Daily Plan must exist)

**Coverage Target:** 80%+

---

**Created:** 2025-01-16 | **Author:** Bob (BMAD)
