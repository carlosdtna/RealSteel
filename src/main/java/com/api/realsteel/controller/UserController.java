package com.api.realsteel.controller;

import com.api.realsteel.dto.UserRequest;
import com.api.realsteel.entity.UserEntity;
import com.api.realsteel.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
@CrossOrigin
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<UserEntity> createUser(@Valid @RequestBody UserRequest userRequest) {
        UserEntity user = new UserEntity();
        user.setUserId(userRequest.getUserId());
        user.setNombre(userRequest.getNombre());
        user.setEmail(userRequest.getEmail());
        user.setPassword(userRequest.getPassword());
        user.setFechaRegistro(java.time.LocalDateTime.now());
        return new ResponseEntity<>(userService.createUser(user), HttpStatus.CREATED);
    }

    @GetMapping({"", "/getAll"})
    public List<UserEntity> getUsers() {
        return userService.getAllUsers();
    }

    @GetMapping("/{id}")
    public UserEntity getUser(@PathVariable String id) {
        return userService.getUserById(id);
    }

    @PutMapping("/{id}")
    public UserEntity updateUser(@PathVariable String id, @Valid @RequestBody UserRequest userRequest) {
        UserEntity update = new UserEntity();
        update.setNombre(userRequest.getNombre());
        update.setEmail(userRequest.getEmail());
        update.setPassword(userRequest.getPassword());
        return userService.updateUser(id, update);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
