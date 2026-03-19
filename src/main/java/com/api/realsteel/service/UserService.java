package com.api.realsteel.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.api.realsteel.entity.UserEntity;
import com.api.realsteel.error.ResourceNotFoundException;
import com.api.realsteel.repository.UserRepository;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserEntity createUser(UserEntity user) {
        return userRepository.save(user);
    }

    public List<UserEntity> getAllUsers() {
        return userRepository.findAll();
    }

    public UserEntity getUserById(String id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id " + id));
    }

    public UserEntity updateUser(String id, UserEntity update) {
        UserEntity existing = getUserById(id);
        if (update.getNombre() != null) existing.setNombre(update.getNombre());
        if (update.getEmail() != null) existing.setEmail(update.getEmail());
        if (update.getPassword() != null) existing.setPassword(update.getPassword());
        return userRepository.save(existing);
    }

    public void deleteUser(String id) {
        UserEntity existing = getUserById(id);
        userRepository.delete(existing);
    }

}
