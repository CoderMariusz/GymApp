One-line: single-line field for auth, search and custom-exercise forms.

```jsx
<Input label="Email" icon="mail" placeholder="marek@example.com" />
<Input label="Weight" numeric align="center" suffix="kg" defaultValue="100" />
<Input label="Password" type="password" error="Incorrect email or password" />
```

The keyboard is the slow path: in the set editor prefer `Stepper` + quick-pick `Chip`s and keep `numeric` inputs as the fallback.
