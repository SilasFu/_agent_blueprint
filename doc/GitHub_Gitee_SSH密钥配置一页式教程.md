# GitHub / Gitee SSH 密钥配置一页式教程

适用目标：

- 在 `WSL Ubuntu` 中配置 `GitHub` 或 `Gitee` 的 SSH 登录
- 以后 `git push`、`git pull` 不再频繁输账号密码
- 让新电脑也能快速复用 Git SSH 配置流程

---

## 1. 先说结论

配置完成后，你会得到这样的效果：

- 仓库地址可以写成 `git@github.com:用户名/仓库.git`
- 日常 `git push` 更顺手
- 更适合长期开发

---

## 2. 你需要在哪操作

所有命令都在 `WSL Ubuntu` 中执行。

提示符通常类似：

```bash
fugui@HW-936:~$
```

不要在 `PowerShell` 里做这套 SSH 配置。

---

## 3. 检查是否已有 SSH 密钥

在 Ubuntu 中执行：

```bash
ls -al ~/.ssh
```

如果你已经看到类似这些文件：

```text
id_ed25519
id_ed25519.pub
```

说明你可能已经有 SSH 密钥了。

如果没有，也没关系，继续下一步生成。

---

## 4. 生成新的 SSH 密钥

最推荐使用 `ed25519`。

执行：

```bash
ssh-keygen -t ed25519 -C "你的邮箱"
```

例如：

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

执行后常见提示：

```text
Enter file in which to save the key (/home/你的用户名/.ssh/id_ed25519):
```

做法：

- 直接按回车，使用默认路径

然后会提示输入密码：

```text
Enter passphrase (empty for no passphrase):
```

两种选择：

- 直接回车，表示不加密私钥，最省事
- 输入一个 SSH 密钥密码，更安全，但以后使用时可能要额外确认

对大多数个人开发场景：

- 可以先直接回车，后面熟悉了再加强安全策略

生成完成后，一般会看到：

```text
Your identification has been saved in /home/你的用户名/.ssh/id_ed25519
Your public key has been saved in /home/你的用户名/.ssh/id_ed25519.pub
```

---

## 5. 查看公钥内容

执行：

```bash
cat ~/.ssh/id_ed25519.pub
```

你会看到一整行内容，类似：

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...... your@email.com
```

你要做的：

- 完整复制这一整行

注意：

- 复制的是 `.pub` 公钥
- 不要把 `id_ed25519` 私钥发给任何人

---

## 6. 添加到 GitHub

### 1. 打开 GitHub

访问 [GitHub](https://github.com/)

### 2. 进入 SSH Key 设置页面

一般路径是：

- 右上角头像
- `Settings`
- `SSH and GPG keys`

### 3. 新增 SSH Key

点击：

- `New SSH key`

填写：

- `Title`：例如 `My WSL Laptop`
- `Key type`：保持默认
- `Key`：粘贴刚才复制的公钥内容

保存即可。

---

## 7. 添加到 Gitee

### 1. 打开 Gitee

访问 [Gitee](https://gitee.com/)

### 2. 进入 SSH 公钥设置

一般在：

- 头像
- `设置`
- `安全设置`
- `SSH公钥`

### 3. 添加公钥

填写：

- 标题：例如 `My WSL Laptop`
- 公钥内容：粘贴刚才复制的那一整行

保存即可。

---

## 8. 测试 SSH 连通性

### 测试 GitHub

执行：

```bash
ssh -T git@github.com
```

第一次通常会看到：

```text
The authenticity of host 'github.com (...)' can't be established.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

输入：

```text
yes
```

如果成功，通常会看到类似：

```text
Hi yourname! You've successfully authenticated, but GitHub does not provide shell access.
```

### 测试 Gitee

执行：

```bash
ssh -T git@gitee.com
```

如果成功，会看到类似欢迎信息。

---

## 9. 把仓库改成 SSH 地址

如果你之前仓库用的是 HTTPS 地址，可以切换成 SSH。

先查看当前远程地址：

```bash
git remote -v
```

如果现在是这种：

```text
https://github.com/你的用户名/项目.git
```

可以改成：

```bash
git remote set-url origin git@github.com:你的用户名/项目.git
```

如果是 Gitee：

```bash
git remote set-url origin git@gitee.com:你的用户名/项目.git
```

然后再检查：

```bash
git remote -v
```

---

## 10. 新项目直接用 SSH 关联远程

### GitHub

```bash
git init
git add .
git commit -m "chore: init project"
git remote add origin git@github.com:你的用户名/项目.git
git branch -M main
git push -u origin main
```

### Gitee

```bash
git init
git add .
git commit -m "chore: init project"
git remote add origin git@gitee.com:你的用户名/项目.git
git branch -M main
git push -u origin main
```

---

## 11. 常见问题

### 1. `Permission denied (publickey)`

说明：

- 平台没绑定你的公钥
- 或你当前用的不是正确私钥

先检查：

```bash
cat ~/.ssh/id_ed25519.pub
```

确认平台上保存的是这一把公钥。

### 2. `Host key verification failed`

可尝试删除旧 known_hosts 再重连：

```bash
ssh-keygen -R github.com
ssh-keygen -R gitee.com
```

然后重新测试：

```bash
ssh -T git@github.com
ssh -T git@gitee.com
```

### 3. 以前生成过很多密钥，自己也分不清

建议：

- 先统一使用默认的 `id_ed25519`
- 确认可用后再考虑多账号多密钥配置

### 4. 新电脑换了以后怎么办

重新执行这份教程即可：

- 重新生成密钥
- 重新把公钥添加到平台

如果你有备份旧私钥，也可以直接恢复旧密钥文件。

---

## 12. 最短执行清单

在 Ubuntu 中执行：

```bash
ssh-keygen -t ed25519 -C "你的邮箱"
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

然后：

- 把公钥粘贴到 `GitHub` 或 `Gitee`
- 把仓库远程地址改成 SSH

---

## 13. 一句话记忆

- `生成公钥`
- `复制 .pub`
- `平台里添加 SSH Key`
- `ssh -T 测试`
- `git remote set-url 改成 SSH`
