# ================================
# Build image
# ================================
FROM swift:5.9-amazonlinux2 as builder

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release --static-swift-stdlib --product CloudFormation

# Create workdir to place files
WORKDIR /workspace

# Copy main executable to workspace area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/CloudFormation" ./

# Copy resources bundled by SPM to workspace area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;


# ================================
# Run image
# ================================
FROM swift:5.9-amazonlinux2-slim

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

# copy executables
COPY --from=builder /build/.build/release /

ENTRYPOINT ["./CloudFormation"]
