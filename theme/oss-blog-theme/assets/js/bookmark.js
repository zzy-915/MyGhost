/**
 * OSS Blog Theme - Article Bookmark / Read-Later Feature
 * Stores bookmarks in localStorage, no backend required.
 */
(function () {
    'use strict';

    var STORAGE_KEY = 'oss_blog_bookmarks';
    var MAX_BOOKMARKS = 500;

    /* ---------- Storage helpers ---------- */

    function getBookmarks() {
        try {
            var raw = localStorage.getItem(STORAGE_KEY);
            return raw ? JSON.parse(raw) : [];
        } catch (e) {
            return [];
        }
    }

    function saveBookmarks(list) {
        try {
            if (list.length > MAX_BOOKMARKS) {
                list = list.slice(0, MAX_BOOKMARKS);
            }
            localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
        } catch (e) {
            console.warn('Bookmark: failed to save', e);
        }
    }

    function isBookmarked(postId) {
        return getBookmarks().some(function (b) {
            return b.id === postId;
        });
    }

    function addBookmark(post) {
        var list = getBookmarks();
        if (!list.some(function (b) { return b.id === post.id; })) {
            list.unshift(post);
            saveBookmarks(list);
        }
        updateBookmarkCount();
    }

    function removeBookmark(postId) {
        var list = getBookmarks().filter(function (b) {
            return b.id !== postId;
        });
        saveBookmarks(list);
        updateBookmarkCount();
    }

    function toggleBookmark(post) {
        if (isBookmarked(post.id)) {
            removeBookmark(post.id);
            return false;
        } else {
            addBookmark(post);
            return true;
        }
    }

    /* ---------- UI: bookmark button on post page ---------- */

    function initPostBookmarkButton() {
        var btn = document.querySelector('[data-bookmark-btn]');
        if (!btn) return;

        var postId = btn.getAttribute('data-post-id');
        var postTitle = btn.getAttribute('data-post-title') || '';
        var postUrl = btn.getAttribute('data-post-url') || window.location.pathname;
        var postExcerpt = btn.getAttribute('data-post-excerpt') || '';
        var postImage = btn.getAttribute('data-post-image') || '';
        var postDate = btn.getAttribute('data-post-date') || '';

        function render(state) {
            btn.classList.toggle('is-bookmarked', state);
            btn.setAttribute('aria-pressed', state ? 'true' : 'false');
            var label = btn.querySelector('.bookmark-label');
            if (label) {
                label.textContent = state ? '已收藏' : '收藏';
            }
            var icon = btn.querySelector('.bookmark-icon');
            if (icon) {
                icon.innerHTML = state
                    ? '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>'
                    : '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>';
            }
        }

        render(isBookmarked(postId));

        btn.addEventListener('click', function (e) {
            e.preventDefault();
            var post = {
                id: postId,
                title: postTitle,
                url: postUrl,
                excerpt: postExcerpt,
                feature_image: postImage,
                published_at: postDate
            };
            var nowBookmarked = toggleBookmark(post);
            render(nowBookmarked);

            // Show a brief toast
            showToast(nowBookmarked ? '已加入收藏' : '已取消收藏');
        });
    }

    /* ---------- UI: bookmark count in nav ---------- */

    function updateBookmarkCount() {
        var count = getBookmarks().length;
        var badge = document.querySelector('[data-bookmark-count]');
        if (badge) {
            badge.textContent = count;
            badge.style.display = count > 0 ? 'inline-flex' : 'none';
        }
    }

    /* ---------- UI: bookmarks list page ---------- */

    function initBookmarksPage() {
        var container = document.querySelector('[data-bookmarks-list]');
        if (!container) return;

        var list = getBookmarks();
        var emptyMsg = document.querySelector('[data-bookmarks-empty]');

        if (list.length === 0) {
            container.innerHTML = '';
            if (emptyMsg) emptyMsg.style.display = 'block';
            return;
        }

        if (emptyMsg) emptyMsg.style.display = 'none';

        var html = list.map(function (post) {
            var excerpt = post.excerpt ? post.excerpt.substring(0, 120) + (post.excerpt.length > 120 ? '...' : '') : '';
            var imageHtml = post.feature_image
                ? '<a class="bookmark-card-image" href="' + post.url + '"><img src="' + post.feature_image + '" alt="' + escapeHtml(post.title) + '" loading="lazy"/></a>'
                : '';
            var dateHtml = post.published_at
                ? '<time class="bookmark-card-date" datetime="' + post.published_at + '">' + formatDate(post.published_at) + '</time>'
                : '';
            return '' +
                '<article class="bookmark-card" data-bookmark-id="' + post.id + '">' +
                    imageHtml +
                    '<div class="bookmark-card-content">' +
                        '<h2 class="bookmark-card-title"><a href="' + post.url + '">' + escapeHtml(post.title) + '</a></h2>' +
                        (excerpt ? '<p class="bookmark-card-excerpt">' + escapeHtml(excerpt) + '</p>' : '') +
                        '<div class="bookmark-card-meta">' +
                            dateHtml +
                            '<button class="bookmark-remove-btn" data-remove-id="' + post.id + '" aria-label="移除收藏">移除</button>' +
                        '</div>' +
                    '</div>' +
                '</article>';
        }).join('');

        container.innerHTML = html;

        // Bind remove buttons
        container.querySelectorAll('.bookmark-remove-btn').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                var id = btn.getAttribute('data-remove-id');
                removeBookmark(id);
                var card = btn.closest('.bookmark-card');
                if (card) {
                    card.style.opacity = '0';
                    card.style.transform = 'translateX(20px)';
                    setTimeout(function () {
                        card.remove();
                        if (container.children.length === 0) {
                            if (emptyMsg) emptyMsg.style.display = 'block';
                        }
                    }, 300);
                }
                showToast('已移除收藏');
            });
        });
    }

    /* ---------- Toast ---------- */

    var toastTimer = null;
    function showToast(message) {
        var toast = document.querySelector('[data-bookmark-toast]');
        if (!toast) {
            toast = document.createElement('div');
            toast.setAttribute('data-bookmark-toast', '');
            toast.className = 'bookmark-toast';
            document.body.appendChild(toast);
        }
        toast.textContent = message;
        toast.classList.add('show');
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(function () {
            toast.classList.remove('show');
        }, 2000);
    }

    /* ---------- Utilities ---------- */

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    function formatDate(iso) {
        try {
            var d = new Date(iso);
            return d.getFullYear() + '-' +
                String(d.getMonth() + 1).padStart(2, '0') + '-' +
                String(d.getDate()).padStart(2, '0');
        } catch (e) {
            return iso;
        }
    }

    /* ---------- Init ---------- */

    function init() {
        initPostBookmarkButton();
        initBookmarksPage();
        updateBookmarkCount();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
