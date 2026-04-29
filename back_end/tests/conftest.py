import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db
from app.main import app
from app.utils.jwt import create_access_token
from app.models.user import User, UserRole

SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def admin_token(client, db_session):
    """管理员 Token"""
    from app.utils.security import hash_password
    admin = User(
        id="test-admin-001",
        phone="13800000001",
        name="测试管理员",
        password_hash=hash_password("123456"),
        role=UserRole.ADMIN,
    )
    db_session.add(admin)
    db_session.commit()
    return create_access_token(data={"sub": admin.id, "role": admin.role.value})


@pytest.fixture
def user_token(client, db_session):
    """普通用户 Token"""
    from app.utils.security import hash_password
    user = User(
        id="test-user-001",
        phone="13900000001",
        name="测试用户",
        password_hash=hash_password("123456"),
        role=UserRole.USER,
    )
    db_session.add(user)
    db_session.commit()
    return create_access_token(data={"sub": user.id, "role": user.role.value})
