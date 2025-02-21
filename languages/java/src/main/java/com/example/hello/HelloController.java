package com.example.hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    private static final Logger logger = LoggerFactory.getLogger(HelloController.class);

  @GetMapping("/")
  public ResponseEntity<HelloResponse> index() {
    logger.info("Request received");
    HelloResponse resp = new HelloResponse();
    resp.message = "Hello, KubeCon!";
    resp.language = "java";
    HttpHeaders headers = new HttpHeaders();
    return new ResponseEntity<>(resp,headers,HttpStatus.OK);
  }
}

