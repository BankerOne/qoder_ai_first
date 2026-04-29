"""用户认证模块测试"""


class TestRegister:
    def test_register_success(self, client):
        """注册成功"""
        resp = client.post("/api/v1/auth/register", json={
            "phone": "13800000001",
            "name": "测试用户",
            "password": "123456",
            "role": "admin",
        })
        assert resp.status_code == 201
        data = resp.json()
        assert data["phone"] == "13800000001"
        assert data["role"] == "admin"
        assert "id" in data

    def test_register_duplicate_phone(self, client):
        """重复手机号返回 409"""
        client.post("/api/v1/auth/register", json={
            "phone": "13800000002",
            "name": "A",
            "password": "123456",
            "role": "user",
        })
        resp = client.post("/api/v1/auth/register", json={
            "phone": "13800000002",
            "name": "B",
            "password": "123456",
            "role": "user",
        })
        assert resp.status_code == 409

    def test_register_invalid_phone(self, client):
        resp = client.post("/api/v1/auth/register", json={
            "phone": "12345",
            "name": "X",
            "password": "123456",
            "role": "user",
        })
        assert resp.status_code == 422

    def test_register_short_password(self, client):
        resp = client.post("/api/v1/auth/register", json={
            "phone": "13800000003",
            "name": "X",
            "password": "123",
            "role": "user",
        })
        assert resp.status_code == 422

    def test_register_invalid_role(self, client):
        resp = client.post("/api/v1/auth/register", json={
            "phone": "13800000004",
            "name": "X",
            "password": "123456",
            "role": "root",
        })
        assert resp.status_code == 422


class TestLogin:
    def test_login_success(self, client):
        client.post("/api/v1/auth/register", json={
            "phone": "13800000010",
            "name": "L",
            "password": "123456",
            "role": "admin",
        })
        resp = client.post("/api/v1/auth/login", json={
            "phone": "13800000010",
            "password": "123456",
        })
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    def test_login_wrong_password(self, client):
        client.post("/api/v1/auth/register", json={
            "phone": "13800000011",
            "name": "L",
            "password": "123456",
            "role": "user",
        })
        resp = client.post("/api/v1/auth/login", json={
            "phone": "13800000011",
            "password": "wrong_password",
        })
        assert resp.status_code == 401

    def test_login_user_not_found(self, client):
        resp = client.post("/api/v1/auth/login", json={
            "phone": "13800000099",
            "password": "123456",
        })
        assert resp.status_code == 401


class TestMe:
    def test_get_me(self, client, admin_token):
        resp = client.get(
            "/api/v1/users/me",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert resp.status_code == 200
        assert resp.json()["role"] == "admin"

    def test_me_without_token(self, client):
        resp = client.get("/api/v1/users/me")
        assert resp.status_code == 401  # 未登录访问被拒绝
