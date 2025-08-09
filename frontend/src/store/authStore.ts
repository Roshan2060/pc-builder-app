import { create } from "zustand"
import axios from "axios"

const API_BASE = "http://localhost:8000/api/v1"

interface User {
  id: number
  username: string
  email: string
}

interface AuthState {
  user: User | null
  isAuthenticated: boolean
  authReady: boolean
  initialized: boolean
  login: (email: string, password: string) => Promise<boolean>
  signup: (username: string, email: string, password: string) => Promise<boolean>
  logout: () => Promise<void>
  fetchUser: () => Promise<void>
  tryAutoLogin: () => Promise<void>
  initAuth: () => Promise<void>
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  authReady: false,
  initialized: false,

  login: async (email, password) => {
    try {
      const res = await axios.post(`${API_BASE}/login/`, {
        email,
        password,
      })
      const { access, refresh, user } = res.data
      localStorage.setItem("access", access)
      localStorage.setItem("refresh", refresh)
      axios.defaults.headers.common["Authorization"] = `Bearer ${access}`
      set({ user, isAuthenticated: true })
      return true
    } catch (err) {
      console.error("Login error:", err)
      return false
    }
  },

  signup: async (username, email, password) => {
    try {
      const res = await axios.post(`${API_BASE}/register/`, {
        username,
        email,
        password,
      })
      const { access, refresh, user } = res.data
      localStorage.setItem("access", access)
      localStorage.setItem("refresh", refresh)
      axios.defaults.headers.common["Authorization"] = `Bearer ${access}`
      set({ user, isAuthenticated: true })
      return true
    } catch (err) {
      console.error("Signup error:", err)
      return false
    }
  },

  logout: async () => {
    try {
      const refresh = localStorage.getItem("refresh")
      if (refresh) {
        await axios.post(`${API_BASE}/logout/`, { refresh }, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("access")}`,
          },
        })
      }
    } catch (err) {
      console.warn("Logout error:", err)
    } finally {
      localStorage.removeItem("access")
      localStorage.removeItem("refresh")
      delete axios.defaults.headers.common["Authorization"]
      set({ user: null, isAuthenticated: false })
    }
  },

  fetchUser: async () => {
    const access = localStorage.getItem("access")
    if (access) {
      axios.defaults.headers.common["Authorization"] = `Bearer ${access}`
    }
    try {
      const res = await axios.get(`${API_BASE}/me/`)
      set({ user: res.data, isAuthenticated: true })
    } catch (err) {
      console.error("Failed to fetch user:", err)
      set({ user: null, isAuthenticated: false })
      throw err
    }
  },

  tryAutoLogin: async () => {
    const access = localStorage.getItem("access")
    const refresh = localStorage.getItem("refresh")
    if (!access && !refresh) {
      set({ authReady: true, isAuthenticated: false, user: null })
      return
    }

    try {
      // Attempt to use current access token
      await get().fetchUser()
    } catch {
      // Try refresh
      if (!refresh) {
        localStorage.removeItem("access")
        set({ user: null, isAuthenticated: false })
        set({ authReady: true })
        return
      }
      try {
        const res = await axios.post(`${API_BASE}/token/refresh/`, { refresh })
        const newAccess = res.data.access
        localStorage.setItem("access", newAccess)
        axios.defaults.headers.common["Authorization"] = `Bearer ${newAccess}`
        await get().fetchUser()
      } catch (refreshError) {
        console.error("Auto login failed:", refreshError)
        localStorage.removeItem("access")
        localStorage.removeItem("refresh")
        delete axios.defaults.headers.common["Authorization"]
        set({ user: null, isAuthenticated: false })
      }
    } finally {
      set({ authReady: true })
    }
  },

  initAuth: async () => {
    if (get().initialized) return
    await get().tryAutoLogin()
    set({ initialized: true })
  },
}))
