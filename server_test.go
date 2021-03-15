package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

var (
	mockDB = map[string]*Student{
		"223445": &Student{"223445", "Mike", "Wong", "3 A", "Singapore"},
		"187562": &Student{"187562", "Amy", "Lin", "3 A", "Cambodia"},
		"100340": &Student{"100340", "Jesse", "Lee", "3 B", "Malaysia"},
		"120909": &Student{"120909", "Amy", "Foster", "3 C", "Thailand"},
	}
	newStuJSON    = `{"id":"100860","firstName":"Jon","lastName":"Snow","class":"2 A","nationality":"unknown"}`
	updateStuJSON = `{"id":"100340","firstName":"Jeff"}`
	deleteStuJSON = `{"id":"120909"}`
)

func TestCreateStudent(t *testing.T) {
	// Setup
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(newStuJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	db = mockDB

	// Assertions
	if assert.NoError(t, createStudent(c)) {
		assert.Equal(t, http.StatusCreated, rec.Code)
		assert.Equal(t, newStuJSON, strings.TrimSpace(rec.Body.String()))
	}
}

func TestUpdateStudent(t *testing.T) {
	// Setup
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(updateStuJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	db = mockDB

	// Assertions
	if assert.NoError(t, updateStudent(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)

		var stu Student
		err := json.NewDecoder(rec.Body).Decode(&stu)
		assert.Equal(t, nil, err)
		assert.Equal(t, "Jeff", stu.FirstName)
	}
}

func TestDeleteStudent(t *testing.T) {
	// Setup
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(deleteStuJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	db = mockDB

	// Assertions
	if assert.NoError(t, deleteStudent(c)) {
		assert.Equal(t, http.StatusNoContent, rec.Code)

		_, ok := db["120909"]
		assert.Equal(t, false, ok)
	}
}

func TestFetchStudentsByClass(t *testing.T) {
	// Setup
	e := echo.New()
	q := make(url.Values)
	q.Set("class", "3 A")
	req := httptest.NewRequest(http.MethodGet, "/?"+q.Encode(), nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	db = mockDB

	// Assertions
	if assert.NoError(t, fetchStudents(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)

		var stuList []Student
		err := json.NewDecoder(rec.Body).Decode(&stuList)
		assert.Equal(t, nil, err)
		assert.Equal(t, 2, len(stuList))
		assert.Equal(t, "3 A", stuList[0].Class)
	}
}

func TestFetchStudentsByID(t *testing.T) {
	// Setup
	e := echo.New()
	q := make(url.Values)
	q.Set("id", "187562")
	req := httptest.NewRequest(http.MethodGet, "/?"+q.Encode(), nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	db = mockDB

	// Assertions
	if assert.NoError(t, fetchStudents(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)

		var stu Student
		err := json.NewDecoder(rec.Body).Decode(&stu)
		assert.Equal(t, nil, err)
		assert.Equal(t, "187562", stu.ID)
	}
}
