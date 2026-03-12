# Changelog


### Performance

**Session Persistence & Token Refresh**

> Users were required to log in again every time the app was closed and reopened.

- App now checks for a stored access token on launch and navigates directly to the home screen when a valid session exists — no login screen is shown on restart.
- Introduced automatic token refresh: when an API call returns `401 Unauthorized`, the app silently requests a new access token using the stored refresh token and retries the original request.
- If the refresh token is also expired or missing, all session data is cleared and the user is redirected to the login screen.
- Refresh token is now stored securely alongside the access token upon successful login.

---

### Design

**Login Screen — Password Visibility Toggle**

> There was no way to reveal the password while typing, making it harder to catch input mistakes.

- Added an eye icon to the password field that toggles between hidden and visible text.

---

**Home Screen — PetSocial Logo**

> The logo in the app bar appeared oversized compared to the Figma design.

- Logo resized to match Figma specifications (30.97 × 32 pt on a 390 pt base) and left-aligned to sit flush with the page content below it.

---

**Home Screen — App Bar Icons**

> The search and hamburger icons did not match the intended design.

- Search button now uses the custom brand SVG icon instead of a generic Material icon.
- Hamburger updated to a two-line offset style matching the Figma design.
- Action button background colour updated to match the design system (`#FEEEE7`).

---

**Home Screen — Story Bar Divider**

> The vertical divider between the "Add Story" tile and the user story cards was too tall and visually misaligned — appearing lower than the card content.

- Divider height reduced and repositioned to align precisely with the centre of the story card images.
- Both the "Add Story" tile and story cards now share identical dimensions for visual consistency.
- Story bar height increased to accommodate the updated card size (Figma reference: 108 pt).
- Story bar now has a 1 pt bottom border separating it from the feed below.


