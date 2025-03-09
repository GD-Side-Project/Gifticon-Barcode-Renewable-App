package com.example.demo.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDate;
import org.springframework.format.annotation.DateTimeFormat;
import com.example.demo.service.GifticonService;
import com.example.demo.entity.GifticonData;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.http.MediaType;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api")
@Tag(name = "Gifticon", description = "기프티콘 API")
public class GifticonApiController {
    private static final Logger logger = LoggerFactory.getLogger(GifticonApiController.class);
    private final GifticonService gifticonService;

    public GifticonApiController(GifticonService gifticonService) {
        this.gifticonService = gifticonService;
    }

    @Operation(summary = "Upload Gifticon", description = "기프티콘 업로드")
    @PostMapping(
        value = "/upload",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<?> uploadGifticon(
            @Parameter(description = "Receiver name")
            @RequestPart(value = "receiver") String receiver,
            
            @Parameter(description = "Product name")
            @RequestPart(value = "productName") String productName,
            
            @Parameter(description = "Expiry date (yyyy-MM-dd)")
            @RequestPart(value = "expiryDate") @DateTimeFormat(pattern = "yyyy-MM-dd") String expiryDate,
            
            @Parameter(description = "Message")
            @RequestPart(value = "message") String message,
            
            @Parameter(description = "Gift image file")
            @RequestPart(value = "giftImage") MultipartFile giftImage,
            
            @Parameter(description = "Product image file")
            @RequestPart(value = "productImage") MultipartFile productImage) {
        try {
            logger.info("Received upload request for receiver: {}", receiver);
            LocalDate parsedExpiryDate = LocalDate.parse(expiryDate);
            GifticonData gifticon = gifticonService.processUpload(
                receiver, productName, parsedExpiryDate, message, giftImage, productImage);
            return ResponseEntity.ok(gifticon);
        } catch (Exception e) {
            logger.error("Error in upload: ", e);
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @GetMapping("/search/{id}")
    public ResponseEntity<?> searchGifticon(@PathVariable String id) {
        try {
            logger.info("Searching for gifticon with id: {}", id);
            return ResponseEntity.ok(gifticonService.findById(id));
        } catch (Exception e) {
            logger.error("Error searching gifticon: ", e);
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse(e.getMessage()));
        }
    }
} 