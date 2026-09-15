import SwiftUI
import PhotosUI

// MARK: - Profile Screen

/// Recreation of the Figma "03-profile" screen: a GRAIN profile with header,
/// stats, bio, action buttons, story highlights, a tab strip, and a post grid.
/// The bottom tab bar is owned by `MainTabView`.
struct ProfileView: View {
    @State private var selectedContentTab: ProfileContentTab = .grid
    @State private var viewModel = ProfileViewModel()
    @State private var isEditingProfile = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var cropItem: CropItem?
    @State private var isShowingMenu = false
    @AppStorage("appTheme") private var appTheme = AppTheme.dark

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        summary
                        bio
                        actions
                        highlights
                        contentTabs
                        postGrid
                    }
                    .padding(.top, 12)
                }
            }
            .background(Color.grainBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $isShowingMenu) {
                SettingsView(appTheme: $appTheme) {
                    await viewModel.signOut()
                }
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileSheet(currentName: viewModel.name, currentBio: viewModel.bio) { newName, newBio in
                await viewModel.saveProfile(name: newName, bio: newBio)
            }
        }
        .fullScreenCover(item: $cropItem) { item in
            ImageCropView(image: item.image) { data in
                Task { await viewModel.uploadAvatar(data) }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button {} label: {
                HStack(spacing: 6) {
                    Text(viewModel.handle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.grainTextPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.grainTextPrimary)
                }
            }

            Spacer()

            Button {} label: {
                Image(systemName: "plus.app")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
            }

            Button {
                isShowingMenu = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
            }
            .accessibilityLabel("Menu")
            .padding(.leading, 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    // MARK: Avatar + Stats

    private var summary: some View {
        HStack(spacing: 28) {
            editableAvatar

            HStack(spacing: 0) {
                stat(viewModel.profile.postsCount, "posts")
                stat(viewModel.profile.followersCount, "followers")
                stat(viewModel.profile.followingCount, "following")
            }
        }
        .padding(.horizontal, 24)
    }

    /// The profile avatar with a photo picker and camera badge, letting the user
    /// choose a new picture that gets uploaded via the view model.
    private var editableAvatar: some View {
        let avatarURL = viewModel.avatarURL
        let isUploading = viewModel.isUploadingAvatar
        return PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
            AvatarCircle(size: 84, url: avatarURL)
                .overlay {
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [Color.grainCoral, Color(hex: "C13584"), Color(hex: "F9CE34")],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        lineWidth: 2.5
                    )
                }
                .overlay {
                    if isUploading {
                        Circle().fill(.black.opacity(0.45))
                        ProgressView().tint(.white)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.grainCoral, in: Circle())
                        .overlay { Circle().strokeBorder(Color.grainBackground, lineWidth: 2) }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Change profile photo")
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage.downsampled(from: data, maxPixels: 2048) {
                    cropItem = CropItem(image: image)
                }
                selectedPhoto = nil
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.grainTextPrimary)
            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(Color.grainTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Bio

    private var bio: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if viewModel.name.isEmpty {
                    Text("Add your name")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(Color.grainTextMuted)
                } else {
                    Text(viewModel.name)
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(Color.grainTextPrimary)
                }
                Button {
                    isEditingProfile = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.grainTextMuted)
                }
                .accessibilityLabel("Edit profile")
            }
            if !viewModel.displayBio.isEmpty {
                Text(viewModel.displayBio)
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.grainTextMuted)
            }
            if !viewModel.profile.link.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "square.stack")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.grainCoral)
                    Text(viewModel.profile.link)
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color.grainCoral)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: Actions

    private var actions: some View {
        HStack(spacing: 8) {
            Button {} label: {
                Text("Follow")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.grainCoral, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {} label: {
                Text("Message")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.grainTextPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {} label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.grainTextPrimary)
                    .frame(width: 40, height: 34)
                    .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Highlights

    @ViewBuilder
    private var highlights: some View {
        if !viewModel.profile.highlights.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(viewModel.profile.highlights) { highlight in
                        VStack(spacing: 6) {
                            AvatarCircle(size: 54)
                                .overlay {
                                    Circle().strokeBorder(Color.grainBorder, lineWidth: 1.5)
                                }
                            Text(highlight.title)
                                .font(.system(size: 10.5))
                                .foregroundStyle(Color.grainTextMuted)
                                .lineLimit(1)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: Content Tabs

    private var contentTabs: some View {
        HStack(spacing: 0) {
            contentTab(.grid, systemImage: "square.grid.3x3")
            contentTab(.reels, systemImage: "play.rectangle")
            contentTab(.tagged, systemImage: "tag")
        }
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.grainBorder)
        }
    }

    private func contentTab(_ tab: ProfileContentTab, systemImage: String) -> some View {
        Button {
            selectedContentTab = tab
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(selectedContentTab == tab ? Color.grainTextPrimary : Color.grainTextMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    if selectedContentTab == tab {
                        Rectangle()
                            .fill(Color.grainTextPrimary)
                            .frame(height: 1.5)
                    }
                }
        }
    }

    // MARK: Post Grid

    @ViewBuilder
    private var postGrid: some View {
        if viewModel.profile.tiles.isEmpty {
            emptyPosts
        } else {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.profile.tiles) { tile in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "24303A"), Color(hex: "0E1418")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) {
                            if let icon = tile.overlayIcon {
                                Image(systemName: icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(6)
                            }
                        }
                }
            }
        }
    }

    /// Shown when the user has no posts yet.
    private var emptyPosts: some View {
        VStack(spacing: 10) {
            Image(systemName: "camera")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Color.grainTextMuted)
            Text("No Posts Yet")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.grainTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }
}

// MARK: - Crop Item

/// Identifiable wrapper so a picked image can drive a `fullScreenCover(item:)`.
private struct CropItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Edit Profile Sheet

/// A sheet for editing the profile's display name and bio. Reports both values
/// through `onSave` and dismisses once the async save completes.
private struct EditProfileSheet: View {
    let currentName: String
    let currentBio: String
    let onSave: (String, String) async -> Void

    @State private var name: String
    @State private var bio: String
    @State private var isSaving = false
    @FocusState private var bioFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Instagram-style bio length cap.
    private let bioLimit = 150

    init(currentName: String, currentBio: String, onSave: @escaping (String, String) async -> Void) {
        self.currentName = currentName
        self.currentBio = currentBio
        self.onSave = onSave
        _name = State(initialValue: currentName)
        _bio = State(initialValue: currentBio)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedBio: String {
        bio.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChanges: Bool {
        !trimmedName.isEmpty && (trimmedName != currentName || trimmedBio != currentBio)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                field(title: "Name") {
                    TextField("Your name", text: $name)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                field(title: "Bio") {
                    VStack(alignment: .trailing, spacing: 4) {
                        TextField("Describe yourself", text: $bio, axis: .vertical)
                            .lineLimit(3...5)
                            .focused($bioFocused)
                            .padding(14)
                            .background(Color.grainField, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onChange(of: bio) { _, newValue in
                                if newValue.count > bioLimit {
                                    bio = String(newValue.prefix(bioLimit))
                                }
                            }

                        Text("\(bio.count)/\(bioLimit)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.grainTextMuted)
                    }
                }

                Spacer()
            }
            .font(.system(size: 16))
            .foregroundStyle(Color.grainTextPrimary)
            .padding(24)
            .background(Color.grainBackground)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                await onSave(trimmedName, trimmedBio)
                                isSaving = false
                                dismiss()
                            }
                        }
                        .disabled(!hasChanges)
                    }
                }
            }
        }
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(Color.grainTextMuted)
            content()
        }
    }
}

#Preview {
    ProfileView()
}
