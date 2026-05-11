from pydantic import BaseModel


class ItemCreate(BaseModel):
    name: str
    description: str | None = None


class ItemRead(BaseModel):
    id: int
    name: str
    description: str | None = None

    model_config = {"from_attributes": True}


class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    full_name: str | None = None
    is_active: bool = True


class UserUpdate(BaseModel):
    email: str | None = None
    password: str | None = None
    full_name: str | None = None
    is_active: bool | None = None


class UserRead(BaseModel):
    id: int
    username: str
    email: str
    full_name: str | None = None
    is_active: bool

    model_config = {"from_attributes": True}
