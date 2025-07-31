#!/bin/bash

# مسیر پروژه (در صورت نیاز تغییر بده)
PROJECT_DIR="SimpleNote"

cd $PROJECT_DIR || exit

echo "📁 Creating folders..."

mkdir -p Views/Login
mkdir -p Views/Notes
mkdir -p Views/Profile
mkdir -p Views/Shared

mkdir -p ViewModels
mkdir -p Models
mkdir -p Services
mkdir -p Networking
mkdir -p Persistence
mkdir -p Extensions
mkdir -p Utils
mkdir -p Resources

echo "📄 Creating initial Swift files..."

# Views
touch Views/Login/LoginView.swift
touch Views/Login/SignupView.swift
touch Views/Notes/NotesListView.swift
touch Views/Notes/NoteDetailView.swift
touch Views/Notes/NoteEditorView.swift
touch Views/Profile/ProfileView.swift
touch Views/Shared/LoadingView.swift
touch Views/Shared/EmptyStateView.swift

# ViewModels
touch ViewModels/AuthViewModel.swift
touch ViewModels/NotesViewModel.swift
touch ViewModels/ProfileViewModel.swift

# Models
touch Models/Note.swift
touch Models/User.swift
touch Models/AuthToken.swift

# Services
touch Services/APIService.swift
touch Services/AuthService.swift
touch Services/NoteService.swift
touch Services/TokenManager.swift

# Networking
touch Networking/APIConstants.swift
touch Networking/NetworkError.swift

# Persistence
touch Persistence/LocalDatabase.swift
touch Persistence/NoteEntity.swift

# Extensions
touch Extensions/View+Extensions.swift
touch Extensions/Date+Format.swift

# Utils
touch Utils/Validator.swift
touch Utils/PaginationHelper.swift

# Resources
touch Resources/Colors.swift

echo "✅ Structure created successfully!"
