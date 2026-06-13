package com.shreyash.accounts.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {


    @GetMapping("/testController")
    public String testController(){
        return "Hey Aryan";
    }

}
