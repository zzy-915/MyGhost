# NOTICE - 第三方代码与许可证声明

本项目基于开源项目进行二次开发，以下声明所有使用的第三方代码、资源及其许可证。

## 上游项目

### Ghost
- **仓库**: https://github.com/TryGhost/Ghost
- **版本**: v6.62.0
- **许可证**: MIT License
- **用途**: 博客系统核心（内容管理、会员、评论、搜索等）
- **修改情况**: 未修改 Ghost 核心代码，仅通过自定义主题进行扩展

### Ghost source 主题
- **来源**: 随 Ghost 安装
- **版本**: v1.7.3
- **许可证**: MIT License
- **用途**: 自定义主题的基线
- **修改情况**: 在主题层添加收藏功能（bookmark.js、bookmark.css），修改 default.hbs、post.hbs、page.hbs、navigation.hbs

## 本人原创代码

以下文件为本人原创，不属于任何第三方项目：

| 文件 | 说明 | 许可证 |
|------|------|--------|
| `theme/oss-blog-theme/assets/js/bookmark.js` | 收藏功能核心逻辑（约250行） | MIT |
| `theme/oss-blog-theme/assets/css/bookmark.css` | 收藏功能样式（约150行） | MIT |
| `theme/oss-blog-theme/page-bookmarks.hbs` | 收藏列表页模板 | MIT |

本人原创代码采用 MIT 许可证，可自由使用、修改和分发。

## 第三方资源

### Lucide Icons
- **来源**: https://lucide.dev/
- **许可证**: ISC License
- **用途**: 收藏按钮和导航栏的内联 SVG 图标（书签图标）
- **使用方式**: 内联 SVG，未修改图标设计

### 演示文章内容
- **来源**: 本人原创
- **许可证**: 自由使用
- **用途**: 实验演示数据（8篇技术文章）

## 许可证文本

### MIT License

```
MIT License

Copyright (c) 2026 学生开发者

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Ghost MIT License

Ghost 项目的完整许可证文本请参考：https://github.com/TryGhost/Ghost/blob/main/LICENSE

## 致谢

感谢 Ghost 团队提供优秀的开源博客系统，以及开源社区的贡献。

---

**声明日期**: 2026-09-07
