package main

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type (
	// Student struct defines the record for each student
	Student struct {
		ID          string `json:"id"`
		FirstName   string `json:"firstName,omitempty"`
		LastName    string `json:"lastName,omitempty"`
		Class       string `json:"class,omitempty"`
		Nationality string `json:"nationality,omitempty"`
	}
)

var (
	db = map[string]*Student{}
)

func main() {

	// Echo instance
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Routes
	e.GET("/fetchStudents", fetchStudents)
	e.POST("/", createStudent)
	e.PUT("/", updateStudent)
	e.DELETE("/", deleteStudent)

	// Start server
	e.Logger.Fatal(e.Start(":1323"))
}

// Handler
func createStudent(c echo.Context) error {
	stu := new(Student)
	if err := c.Bind(stu); err != nil {
		return c.String(http.StatusOK, "Invalid query\n")
	}

	// If student id already exists in database
	if _, ok := db[stu.ID]; ok {
		return c.String(http.StatusOK, "Student Id already exists\n")
	}

	// add record to database
	db[stu.ID] = stu
	return c.JSON(http.StatusCreated, stu)
}

func updateStudent(c echo.Context) error {
	stu := new(Student)
	if err := c.Bind(stu); err != nil {
		return c.String(http.StatusOK, "Invalid query\n")
	}

	// If student id doesn't exist in database
	if _, ok := db[stu.ID]; !ok {
		return c.String(http.StatusOK, "Student Id is not found\n")
	}

	// Update each field
	if len(stu.FirstName) > 0 {
		db[stu.ID].FirstName = stu.FirstName
	}
	if len(stu.FirstName) > 0 {
		db[stu.ID].LastName = stu.FirstName
	}
	if len(stu.Nationality) > 0 {
		db[stu.ID].Nationality = stu.Nationality
	}
	if len(stu.Class) > 0 {
		db[stu.ID].Class = stu.Class
	}
	return c.JSON(http.StatusOK, db[stu.ID])
}

func deleteStudent(c echo.Context) error {
	stu := new(Student)
	if err := c.Bind(stu); err != nil {
		return c.String(http.StatusOK, "Invalid query\n")
	}

	// If student id doesn't exist in database
	if _, ok := db[stu.ID]; !ok {
		return c.String(http.StatusOK, "Student Id is not found\n")
	}

	// delete record from database
	delete(db, stu.ID)
	return c.NoContent(http.StatusNoContent)
}

func fetchStudents(c echo.Context) error {
	class := c.QueryParam("class")
	id := c.QueryParam("id")

	if len(id) > 0 {
		// query by Id
		if _, ok := db[id]; ok {
			return c.JSON(http.StatusOK, db[id])
		}
		return c.String(http.StatusOK, "Student Id is not found\n")
	}

	res := []*Student{}
	if len(class) > 0 {
		// query by class
		for _, ele := range db {
			if len(ele.Class) > 0 {
				if ele.Class == class {
					res = append(res, ele)
				}
			}
		}
	}

	return c.JSON(http.StatusOK, res)
}
