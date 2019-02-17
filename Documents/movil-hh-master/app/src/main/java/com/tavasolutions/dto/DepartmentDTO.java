package com.tavasolutions.dto;

public class DepartmentDTO {

    int id;
    String name;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return name;
    }

    public DepartmentDTO(int id, String name) {
        this.id = id;
        this.name = name;
    }
}
