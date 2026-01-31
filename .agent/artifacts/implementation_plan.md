# Full Feature Implementation Plan

## Overview
This document outlines the plan to implement complete data layer and API integration for all features in the TargetSocialApp Flutter application.

## Current State Analysis

### ✅ Features with Complete Architecture (Auth, Shop)
- Data Sources (Local + Remote)
- Repositories (Interface + Implementation)
- Controllers/State Management
- Models/Entities

### ⚠️ Features Needing Data Layer (Social, Messages, Profile, Discover, AI Hub, AI Tools, Business)
- Only have UI/Presentation layer
- Using mock/static data
- Need full data layer implementation

---

## Implementation Priority

### Phase 1: Core Social Features
1. **Posts** - Create, Read, Update, Delete posts
2. **Feed** - Home feed, Discover feed
3. **Interactions** - Likes, Comments, Shares
4. **Follow System** - Follow/Unfollow users

### Phase 2: User & Profile
1. **Profile** - View/Edit profile
2. **User Search** - Find users
3. **User Stats** - Followers, Following, Posts count

### Phase 3: Messaging
1. **Conversations** - List, Create
2. **Messages** - Send, Receive, Real-time updates
3. **Notifications** - Push notifications setup

### Phase 4: Business Features
1. **Business Profiles** - Create, Manage
2. **Products** - CRUD operations
3. **Orders** - Order management
4. **Reviews** - Customer reviews

### Phase 5: AI Features
1. **AI Hub** - AI agents listing
2. **AI Tools** - Tool configurations
3. **AI Chat** - Conversational AI

---

## API Endpoints Required (Backend)

### Auth Endpoints (Existing)
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/google-login
- POST /api/auth/refresh-token
- POST /api/auth/logout

### Posts Endpoints
- GET /api/posts (Feed)
- GET /api/posts/{id}
- POST /api/posts
- PUT /api/posts/{id}
- DELETE /api/posts/{id}
- POST /api/posts/{id}/like
- DELETE /api/posts/{id}/like
- GET /api/posts/{id}/comments
- POST /api/posts/{id}/comments

### Users Endpoints
- GET /api/users/{id}
- GET /api/users/{id}/posts
- GET /api/users/{id}/followers
- GET /api/users/{id}/following
- POST /api/users/{id}/follow
- DELETE /api/users/{id}/follow
- PUT /api/users/me (Update profile)
- GET /api/users/search?q={query}

### Messages Endpoints
- GET /api/conversations
- GET /api/conversations/{id}
- POST /api/conversations
- GET /api/conversations/{id}/messages
- POST /api/conversations/{id}/messages
- WebSocket /ws/messages (Real-time)

### Business Endpoints
- GET /api/businesses
- GET /api/businesses/{id}
- POST /api/businesses
- PUT /api/businesses/{id}
- GET /api/businesses/{id}/products
- POST /api/businesses/{id}/products

### Shop Endpoints (Existing)
- GET /api/products
- GET /api/products/{id}
- GET /api/cart
- POST /api/cart/items
- DELETE /api/cart/items/{id}
- POST /api/orders
- GET /api/orders

---

## File Structure to Create

```
lib/features/
├── social/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── posts_remote_data_source.dart
│   │   │   └── posts_local_data_source.dart
│   │   ├── repositories/
│   │   │   └── posts_repository_impl.dart
│   │   └── models/
│   │       ├── post_model.dart
│   │       └── comment_model.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── post.dart
│   │   │   └── comment.dart
│   │   └── repositories/
│   │       └── posts_repository.dart
│   └── application/
│       └── posts_controller.dart
│
├── profile/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── profile_remote_data_source.dart
│   │   │   └── profile_local_data_source.dart
│   │   ├── repositories/
│   │   │   └── profile_repository_impl.dart
│   │   └── models/
│   │       └── user_profile_model.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_profile.dart
│   │   └── repositories/
│   │       └── profile_repository.dart
│   └── application/
│       └── profile_controller.dart
│
├── messages/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── messages_remote_data_source.dart
│   │   │   └── messages_local_data_source.dart
│   │   ├── repositories/
│   │   │   └── messages_repository_impl.dart
│   │   └── models/
│   │       ├── conversation_model.dart
│   │       └── message_model.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── conversation.dart
│   │   │   └── message.dart
│   │   └── repositories/
│   │       └── messages_repository.dart
│   └── application/
│       └── messages_controller.dart
│
├── business/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── business_remote_data_source.dart
│   │   ├── repositories/
│   │   │   └── business_repository_impl.dart
│   │   └── models/
│   │       └── business_model.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── business.dart
│   │   └── repositories/
│   │       └── business_repository.dart
│   └── application/
│       └── business_controller.dart
```

---

## Implementation Status

- [x] Phase 1: Core Social Features
  - [x] Post entity and model
  - [x] Posts repository interface
  - [x] Posts remote data source
  - [x] Posts local data source (caching)
  - [x] Posts repository implementation
  - [x] Posts controller
  - [ ] Connect UI to controller (pending)

- [x] Phase 2: User & Profile
  - [x] UserProfile entity and model
  - [x] Profile repository interface
  - [x] Profile remote data source
  - [x] Profile repository implementation
  - [x] Profile controller
  - [ ] Connect UI to controller (pending)

- [x] Phase 3: Messaging
  - [x] Conversation/Message entities
  - [x] Messages repository interface
  - [x] Message models with JSON
  - [x] Messages repository implementation
  - [x] Messages controller
  - [x] Real-time stream support
  - [ ] WebSocket integration (needs backend)
  - [ ] Connect UI to controller (pending)

- [x] Phase 4: Business Features
  - [x] Business entity and model
  - [x] Business repository interface
  - [x] Business repository implementation
  - [x] Business controller
  - [ ] Connect UI to controller (pending)

- [x] Phase 5: AI Features
  - [x] AI agents/tools entities
  - [x] AI repository interface
  - [x] AI repository implementation
  - [x] AI controller with streaming
  - [x] Subscription management
  - [ ] Connect UI to controller (pending)

---

## Notes
- All remote data sources will have a `useMockData` flag for development
- Local data sources will use SharedPreferences or Hive for caching
- Controllers will use Riverpod for state management
- All API calls will go through the ApiClient in core/network
