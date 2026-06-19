# Recover Lost Commit bằng `git reflog`

## Mục tiêu

Khôi phục một commit đã bị mất sau khi thực hiện `git reset --hard`.

---

## Bước 1: Tạo một commit

Tạo file mới:

```bash
echo "lost" > lostcommit.txt
```

Thêm file vào staging và commit:

```bash
git add .
git commit -m "feat: lost commit"
```

Kiểm tra lịch sử:

```bash
git log --oneline
```

Ví dụ:

```text
abc1234 Lost commit
def5678 Previous commit
```

---

## Bước 2: Giả lập mất commit

Quay về commit trước đó:

```bash
git reset --hard HEAD~1
```

Lúc này commit `Lost commit` không còn xuất hiện trong lịch sử hiện tại.

Kiểm tra:

```bash
git log --oneline
```

Ví dụ:

```text
def5678 Previous commit
```

---

## Bước 3: Tìm lại commit bằng `reflog`

Hiển thị lịch sử di chuyển của `HEAD`:

```bash
git reflog
```

Ví dụ:

```text
abc1234 HEAD@{1}: commit: Lost commit
def5678 HEAD@{0}: reset: moving to HEAD~1
```

Ghi lại SHA của commit cần khôi phục (ví dụ: `abc1234`).

---

## Bước 4: Khôi phục commit

Tạo một branch mới từ commit vừa tìm được:

```bash
git checkout -b recovered abc1234
```

Hoặc với Git mới:

```bash
git switch -c recovered abc1234
```

---

## Bước 5: Kiểm tra kết quả

Kiểm tra lịch sử commit:

```bash
git log --oneline
```

Ví dụ:

```text
abc1234 Lost commit
def5678 Previous commit
```

Kiểm tra branch hiện tại:

```bash
git branch
```

Kết quả:

```text
* recovered
  main
```

Commit đã được khôi phục thành công trên branch `recovered`.
![](./screenshots/part-B.png)
---

## Giải thích

- `git reset --hard` có thể làm mất commit khỏi lịch sử của branch.
- `git reflog` vẫn lưu lại lịch sử di chuyển của `HEAD`, giúp tìm lại SHA của commit.
- `git checkout -b recovered <SHA>` tạo một branch mới trỏ đến commit đó, từ đó có thể tiếp tục làm việc hoặc merge lại vào branch chính nếu cần.