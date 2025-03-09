package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.entity.GifticonData;

public interface GifticonRepository extends JpaRepository<GifticonData, String> {
} 