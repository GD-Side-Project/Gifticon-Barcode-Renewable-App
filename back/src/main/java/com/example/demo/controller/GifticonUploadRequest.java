package com.example.demo.controller;

import org.springframework.web.multipart.MultipartFile;

public class GifticonUploadRequest {
    private MultipartFile giftImage;
    private MultipartFile productImage;

    public GifticonUploadRequest() {}

    public GifticonUploadRequest(MultipartFile giftImage, MultipartFile productImage) {
        this.giftImage = giftImage;
        this.productImage = productImage;
    }

    public MultipartFile getGiftImage() {
        return giftImage;
    }

    public void setGiftImage(MultipartFile giftImage) {
        this.giftImage = giftImage;
    }

    public MultipartFile getProductImage() {
        return productImage;
    }

    public void setProductImage(MultipartFile productImage) {
        this.productImage = productImage;
    }
} 