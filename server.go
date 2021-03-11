package main

import (
  "net/http"
  "github.com/labstack/echo/v4"
  "github.com/labstack/echo/v4/middleware"
)

type (
	Student struct {
		Id          string `json:"id"`
		FirstName   string `json:"firstName,omitempty"`
        LastName    string `json:"lastName,omitempty"`
        Class       string `json:"class,omitempty"`
        Nationality string `nationality,omitempty`
	}
)

var (
	students = map[string]*user{}
	seq   = 1
)

func main() {
    // Echo instance
    e := echo.New()

     // Middleware
    e.Use(middleware.Logger())
    e.Use(middleware.Recover())

     // Routes
    e.GET("/", hello)

    // Start server
    e.Logger.Fatal(e.Start(":1323"))
}

// Handler
func hello(c echo.Context) error {
    return c.String(http.StatusOK, "Hello, World!")
}

func creatStudent(c echo.Context) error {
    stu := new(Student)
	if err := c.Bind(stu); err != nil {
		return err
	}
    students[stu.Id] = stu
	return c.JSON(http.StatusCreated, stu)
}

func updateStudent(c echo.Context) error {
    stu := new(Student)
    if err := c.Bind(stu); err != nil {
        return err
    }
    
    return c.JSON(http.StatusOK, students[stu.Id])
}

func deleteStudent(c echo.Context) error {
    stu := new(Student)
    if err := c.Bind(stu); err != nil {
        return err
    }
    delete(students, stu.Id)
    return c.NoContent(http.StatusNoContent)
}

func fetchStudents(c. echo.Context) error {
    class := c.QueryParam("class")
    id := c.QueryParam("id")
    return c.String(http.StatusOK, "team:" + team + ", member:" + member)
}
