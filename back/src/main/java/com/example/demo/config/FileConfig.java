package com.example.demo.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import javax.annotation.PostConstruct;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.springframework.lang.NonNull;

@Configuration
public class FileConfig implements WebMvcConfigurer {
    private static final Logger logger = LoggerFactory.getLogger(FileConfig.class);

    @Value("${upload.path}")
    private String uploadPath;

    @PostConstruct
    public void init() {
        try {
            Path uploadDir = Paths.get(uploadPath);
            Files.createDirectories(uploadDir.resolve("giftImage"));
            Files.createDirectories(uploadDir.resolve("productImage"));
            logger.info("Created upload directories at: {}", uploadDir.toAbsolutePath());
        } catch (IOException e) {
            logger.error("Failed to create upload directories", e);
            throw new RuntimeException("Could not create upload directories!", e);
        }
    }

    @Override
    public void addResourceHandlers(@NonNull ResourceHandlerRegistry registry) {
        Path uploadDir = Paths.get(uploadPath);
        String uploadAbsolutePath = uploadDir.toFile().getAbsolutePath();

        registry.addResourceHandler("/images/**")
                .addResourceLocations("file:" + uploadAbsolutePath + "/");
        
        logger.info("Resource handler added for path: {}", uploadAbsolutePath);
    }
} 