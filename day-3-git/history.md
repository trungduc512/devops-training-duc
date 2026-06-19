1. Tạo branch feature-a, commit 3 lần (3 file khác nhau).
![](./screenshots/part-A-step-1.png)

2. Quay về main, tạo branch feature-b, commit 2 lần (chỉnh đè cùng file với feature-a).
![](./screenshots/part-A-step-2.png)

3. Rebase feature-b lên feature-a → chủ động gây conflict → resolve thủ công.![](./screenshots/part-A-step-3.png)

4. Tạo branch hotfix, commit 1 fix.
![](./screenshots/part-A-step-4.png)

5. cherry-pick commit hotfix sang cả main và feature-a.
![](./screenshots/part-A-step-5.png)

6. Squash 3 commit của feature-a thành 1 bằng rebase -i.
![](./screenshots/part-A-step-6.png)