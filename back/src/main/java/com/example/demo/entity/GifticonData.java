package com.example.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "gifticon_data")
public class GifticonData {
    @Id
    private String id;  // UUID를 저장할 String 타입의 id

    private String receiver;
    private String productName;
    private LocalDateTime expiryDate;
    private String message;
    private String giftImagePath;    // /upload/giftImage/{UUID}.확장자
    private String productImagePath; // /upload/productImage/{UUID}.확장자

    // 기본 생성자 추가
    public GifticonData() {
    }

    // 기존 생성자 유지
    public GifticonData(String receiver, String productName, LocalDateTime expiryDate, String message) {
        this.receiver = receiver;
        this.productName = productName;
        this.expiryDate = expiryDate;
        this.message = message;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public LocalDateTime getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDateTime expiryDate) { this.expiryDate = expiryDate; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getGiftImagePath() { return giftImagePath; }
    public void setGiftImagePath(String giftImagePath) { this.giftImagePath = giftImagePath; }

    public String getProductImagePath() { return productImagePath; }
    public void setProductImagePath(String productImagePath) { this.productImagePath = productImagePath; }
} 