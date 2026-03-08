# GitHub Pages 部署指南（简化版）

目标：把当前的简易留言板部署到 GitHub Pages，方便公开访问。

前提条件
- 你有一个 GitHub 账号，并且有权限创建/管理仓库。
- 代码已经在本地准备就绪，包含 index.html 等静态文件（当前目录即为发布目录）。
- 如果要使用自动部署，需要在仓库里启用 GitHub Actions（仓库默认包含 GITHUB_TOKEN 权限）。

步骤摘要

本地到 GitHub 的一键脚本（可复制执行）
#!/bin/bash
# 在当前目录执行
# 依赖：Git
git init
git add -A
git commit -m "feat: initial commit for GitHub Pages deploy"
git branch -M main
git remote add origin https://github.com/your-username/agent-forum.git
git push -u origin main

注意
- 以上脚本中的仓库地址请替换成你实际的 GitHub 仓库地址。
- 第一次推送后，GitHub Pages 可能需要一点时间来部署，刷新页面即可看到留言板。

- 以上脚本中的仓库地址请替换成你实际的 GitHub 仓库地址。
- 第一次推送后，GitHub Pages 可能需要一点时间来部署，刷新页面即可看到留言板。
