import os
import sqlite3
from contextlib import contextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field


class TaskCreate(BaseModel):
    title: str = Field(min_length=1)
    description: str = ""
    quadrant: int = 4


class TaskUpdate(BaseModel):
    title: str | None = None
    description: str | None = None


class TaskQuadrant(BaseModel):
    quadrant: int = Field(ge=1, le=4)


class TaskComplete(BaseModel):
    completed: bool = True


DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
DB_PATH = os.path.join(DATA_DIR, "tasks.db")


@contextmanager
def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()


def row_to_task(row: sqlite3.Row) -> dict:
    return {
        "id": row["id"],
        "title": str(row["title"]) if row["title"] is not None else "",
        "description": str(row["description"]) if row["description"] is not None else "",
        "quadrant": row["quadrant"],
        "isCompleted": bool(row["is_completed"]),
        "createdAt": row["created_at"],
        "orderIndex": row["order_index"] if "order_index" in row.keys() else 0,
    }


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


if os.path.isdir(os.path.join(os.path.dirname(os.path.dirname(__file__)), "webui")):
    app.mount("/", StaticFiles(directory=os.path.join(os.path.dirname(os.path.dirname(__file__)), "webui"), html=True), name="webui")


@app.get("/api/tasks")
def get_tasks():
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM tasks WHERE is_completed = 0 ORDER BY quadrant ASC, order_index ASC, created_at DESC")
        rows = cur.fetchall()
        return [row_to_task(r) for r in rows]


@app.get("/api/tasks/completed")
def get_completed_tasks():
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM tasks WHERE is_completed = 1 ORDER BY created_at DESC")
        rows = cur.fetchall()
        return [row_to_task(r) for r in rows]


@app.post("/api/tasks")
def create_task(payload: TaskCreate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO tasks (title, description, quadrant) VALUES (?, ?, ?)",
            (payload.title, payload.description, payload.quadrant),
        )
        conn.commit()
        task_id = cur.lastrowid
        cur.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
        row = cur.fetchone()
        return row_to_task(row)


@app.patch("/api/tasks/{task_id}")
def update_task(task_id: int, payload: TaskUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
        if cur.fetchone() is None:
            raise HTTPException(status_code=404)
        if payload.title is not None or payload.description is not None:
            cur.execute(
                "UPDATE tasks SET title = COALESCE(?, title), description = COALESCE(?, description) WHERE id = ?",
                (payload.title, payload.description, task_id),
            )
            conn.commit()
        cur.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
        row = cur.fetchone()
        return row_to_task(row)


@app.patch("/api/tasks/{task_id}/quadrant")
def move_task(task_id: int, payload: TaskQuadrant):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("UPDATE tasks SET quadrant = ? WHERE id = ?", (payload.quadrant, task_id))
        conn.commit()
        cur.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404)
        return row_to_task(row)


@app.patch("/api/tasks/{task_id}/complete")
def complete_task(task_id: int, payload: TaskComplete):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("UPDATE tasks SET is_completed = ? WHERE id = ?", (1 if payload.completed else 0, task_id))
        conn.commit()
        cur.execute("SELECT * FROM tasks WHERE id = ?", (task_id,))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404)
        return row_to_task(row)


@app.delete("/api/tasks/{task_id}")
def delete_task(task_id: int):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("DELETE FROM tasks WHERE id = ?", (task_id,))
        conn.commit()
        return {"ok": True}


@app.delete("/api/tasks/completed")
def clear_completed():
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("DELETE FROM tasks WHERE is_completed = 1")
        conn.commit()
        return {"ok": True}