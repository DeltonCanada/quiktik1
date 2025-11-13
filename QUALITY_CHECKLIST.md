# Pre-Commit Quality Checklist for QuikTik

This checklist ensures code quality and prevents common issues before committing changes.

## 🔍 Automated Checks

Run these commands before committing:

```bash
# 1. Check for code analysis issues
dart analyze

# 2. Format code consistently
dart format lib/ --set-exit-if-changed

# 3. Run tests (when available)
flutter test

# 4. Check for deprecated methods
powershell -ExecutionPolicy Bypass -File scripts/check_deprecated.ps1
```

## ✅ Manual Checks

- [ ] No `withOpacity()` calls (use `withValues(alpha: x)` instead)
- [ ] No unnecessary `const` keywords
- [ ] All imports are used
- [ ] Proper error handling in place
- [ ] UI components use professional styling
- [ ] No hardcoded strings (use localization)
- [ ] Responsive design considerations
- [ ] Accessibility features implemented

## 🚀 Performance Checks

- [ ] No unnecessary rebuilds
- [ ] Efficient list rendering (ListView.builder for large lists)
- [ ] Proper disposal of controllers and streams
- [ ] Optimized image loading
- [ ] Minimal widget tree depth

## 📱 Platform Checks

- [ ] Web compatibility verified
- [ ] Mobile responsiveness tested
- [ ] Cross-platform UI consistency
- [ ] Platform-specific code properly conditioned

## 🎨 Professional Standards

- [ ] Material Design 3 guidelines followed
- [ ] Consistent color scheme usage
- [ ] Professional animations and transitions
- [ ] Proper loading states
- [ ] Error states handled gracefully

## 📝 Documentation

- [ ] Complex functions documented
- [ ] TODO comments have context
- [ ] API changes documented in changelog
- [ ] README updated if needed

---

**Remember**: These checks help maintain code quality and prevent issues from appearing again!