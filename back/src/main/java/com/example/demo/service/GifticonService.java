package com.example.demo.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDate;
import java.util.UUID;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import com.example.demo.repository.GifticonRepository;
import com.example.demo.entity.GifticonData;

@Service
public class GifticonService {
    private static final Logger logger = LoggerFactory.getLogger(GifticonService.class);
    private final GifticonRepository gifticonRepository;
    private final String uploadDir = "upload";
    private final String giftImageDir = "giftImage";
    private final String productImageDir = "productImage";

    public GifticonService(GifticonRepository gifticonRepository) {
        this.gifticonRepository = gifticonRepository;
        try {
            createDirectories();
        } catch (Exception e) {
            logger.error("Failed to create upload directories", e);
        }
    }

    public GifticonData processUpload(String receiver, String productName, LocalDate expiryDate,
                                    String message, MultipartFile giftImage, MultipartFile productImage) {
        try {
            String uuid = UUID.randomUUID().toString();
            
            String giftImagePath = saveImage(giftImage, giftImageDir, uuid);
            String productImagePath = saveImage(productImage, productImageDir, uuid);
            
            GifticonData gifticon = new GifticonData();
            gifticon.setId(uuid);
            gifticon.setReceiver(receiver);
            gifticon.setProductName(productName);
            gifticon.setExpiryDate(expiryDate.atStartOfDay());
            gifticon.setMessage(message);
            gifticon.setGiftImagePath(giftImagePath);
            gifticon.setProductImagePath(productImagePath);
            
            return gifticonRepository.save(gifticon);
        } catch (Exception e) {
            logger.error("Error processing upload: ", e);
            throw new RuntimeException("Failed to process upload: " + e.getMessage());
        }
    }

    private void createDirectories() throws Exception {
        Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        Path giftPath = uploadPath.resolve(giftImageDir);
        Path productPath = uploadPath.resolve(productImageDir);

        Files.createDirectories(giftPath);
        Files.createDirectories(productPath);
        
        logger.info("Created directories: {} and {}", giftPath, productPath);
    }

    private String saveImage(MultipartFile file, String subDir, String uuid) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }

        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String filename = uuid + extension;
        
        Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        Path destinationPath = uploadPath.resolve(Paths.get(subDir, filename));
        
        Files.copy(file.getInputStream(), destinationPath, StandardCopyOption.REPLACE_EXISTING);
        
        logger.info("Saved file to: {}", destinationPath);
        
        return "/upload/" + subDir + "/" + filename;
    }

    public GifticonData findById(String id) {
        logger.info("Finding gifticon with id: {}", id);
        return gifticonRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Gifticon not found with id: " + id));
    }
}