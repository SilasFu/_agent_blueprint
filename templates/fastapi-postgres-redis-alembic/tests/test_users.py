from collections.abc import Generator

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import Base, get_db
from app.main import app


engine = create_engine(
    "sqlite://",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base.metadata.create_all(bind=engine)


def override_get_db() -> Generator[Session, None, None]:
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_user_crud_flow() -> None:
    create_response = client.post(
        "/users",
        json={
            "username": "demo-user",
            "email": "demo@example.com",
            "password": "secret123",
            "full_name": "Demo User",
            "is_active": True,
        },
    )

    assert create_response.status_code == 201
    created_user = create_response.json()
    assert created_user["username"] == "demo-user"
    assert created_user["email"] == "demo@example.com"
    assert "password_hash" not in created_user

    user_id = created_user["id"]

    list_response = client.get("/users")
    assert list_response.status_code == 200
    assert len(list_response.json()) >= 1

    detail_response = client.get(f"/users/{user_id}")
    assert detail_response.status_code == 200
    assert detail_response.json()["id"] == user_id

    update_response = client.patch(
        f"/users/{user_id}",
        json={"full_name": "Updated User", "is_active": False},
    )
    assert update_response.status_code == 200
    assert update_response.json()["full_name"] == "Updated User"
    assert update_response.json()["is_active"] is False

    delete_response = client.delete(f"/users/{user_id}")
    assert delete_response.status_code == 204

    missing_response = client.get(f"/users/{user_id}")
    assert missing_response.status_code == 404
