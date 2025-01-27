using DeformableRegistration.ImageProcessing
using DeformableRegistration.Types
using Images
using Base.Test
using MicroLogging

function checkImageProperties(img::regImage)
    # check if image has two dimensions
    @test ndims(img.data) == 2

    # check if image values are between 0 and 1
    @test float64(minfinite(img.data))>=0.0
    @test float64(maxfinite(img.data))<=1.0
    # check if colorspace is float
    @test eltype(img.data) <: Float64
end

@testset "ImageProcessing" begin
@testset "load or create image" begin
    # test loadImage
    testimage = dirname(Base.source_path()) * "/testdata/luebeck.jpg"
    img = loadImage(testimage)
    checkImageProperties(img)
    # check if spatial domain is the one that was specified
    img = loadImage(testimage)
    @test img.voxelsize == [1.0,1.0]
    @test img.shift == [0.0,0.0]

    # test createImage
    imgdata = rand(43,123)
    img = createImage(imgdata)
    checkImageProperties(img)
    @test size(imgdata) == (43,123)
end

@testset "restriction" begin
    # test restrictResolutionToLevel
    imgdata = rand(64,128)
    img = createImage(imgdata)
    checkImageProperties(img)
    restrictedImage = restrictResolutionToLevel(img,1)
    @test img.voxelsize[1] == ceil(restrictedImage.voxelsize[1] / 2)
    @test img.voxelsize[2] == ceil(restrictedImage.voxelsize[2] / 2)


    # test restrictResolutionToLevel
    imgdata = rand(65,128)
    img = createImage(imgdata)
    # check image properties for each level of the created image
    restrictedImage = restrictResolutionToLevel(img,2)
    @test img.voxelsize[1] == ceil(ceil(restrictedImage.voxelsize[1] / 2) / 2)
    @test img.voxelsize[2] == ceil(ceil(restrictedImage.voxelsize[2] / 2) / 2)

end

@testset "write image" begin
    using FileIO, QuartzImageIO

    imgdata = rand(64,128) # x \in [0, 1]
    img = createImage(imgdata)
    # load image, write image, load the written image and compare it
    testimagewrite = dirname(Base.source_path()) * "/testdata/testimage_write.jpg"
    save(testimagewrite, img.data)
    imgwritten = loadImage(testimagewrite)
    A = convert(Array{Float64,2},img.data)
    B = convert(Array{Float64,2},imgwritten.data)
    @test norm(A .- B)/length(A) < 0.0001
end
end
