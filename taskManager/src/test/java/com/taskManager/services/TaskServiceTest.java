package com.taskManager.services;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.MockitoAnnotations;

import com.taskManager.model.Task;
import com.taskManager.repository.TaskRepository;

class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @InjectMocks
    private TaskService taskService;

    private Task task1;
    private Task task2;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        task1 = new Task(1L, "Task One", "Description One", false);
        task2 = new Task(2L, "Task Two", "Description Two", true);
    }

    @Test
    void testGetAllTasks() {
        when(taskRepository.findAll()).thenReturn(Arrays.asList(task1, task2));

        List<Task> tasks = taskService.getAllTasks();

        assertEquals(2, tasks.size());
        verify(taskRepository, times(1)).findAll();
    }

   @Test
void testGetTaskById() {
    when(taskRepository.findById(1L)).thenReturn(Optional.of(task1));

 Task result = taskService.getTaskById(1L);
assertNotNull(result);
assertEquals("Task One", result.getTitle());

    verify(taskRepository, times(1)).findById(1L);
}


    @Test
    void testCreateTask() {
        when(taskRepository.save(any(Task.class))).thenReturn(task1);

        Task createdTask = taskService.createTask(task1);

        assertNotNull(createdTask);
        assertEquals("Task One", createdTask.getTitle());
        verify(taskRepository, times(1)).save(task1);
    }

    @Test
    void testUpdateTaskWhenExists() {
        when(taskRepository.existsById(1L)).thenReturn(true);
        when(taskRepository.save(any(Task.class))).thenReturn(task1);

        Task updatedTask = taskService.updateTask(1L, task1);

        assertNotNull(updatedTask);
        verify(taskRepository, times(1)).save(task1);
    }

    @Test
    void testUpdateTaskWhenNotExists() {
        when(taskRepository.existsById(1L)).thenReturn(false);

        Task updatedTask = taskService.updateTask(1L, task1);

        assertNull(updatedTask);
        verify(taskRepository, never()).save(any(Task.class));
    }

    @Test
    void testDeleteTask() {
        doNothing().when(taskRepository).deleteById(1L);

        taskService.deleteTask(1L);

        verify(taskRepository, times(1)).deleteById(1L);
    }
}
