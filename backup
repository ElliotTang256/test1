import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

// Setup the scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x000033); // Dark blue, almost black
scene.fog = new THREE.Fog(0x000033, 20, 80); // Matching fog color

const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
camera.position.set(0, 10, 20); // Adjusted camera position to zoom out

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(window.devicePixelRatio);
renderer.shadowMap.enabled = true;
document.body.appendChild(renderer.domElement);

// Lighting
const keyLight = new THREE.DirectionalLight(0xffffff, 1.0);
keyLight.position.set(-1, 2, 4);
keyLight.castShadow = true; // Enable shadow casting for keyLight
scene.add(keyLight);

const fillLight = new THREE.DirectionalLight(0xffffff, 0.8);
fillLight.position.set(1, 1, 2);
scene.add(fillLight);

const backLight = new THREE.DirectionalLight(0xffffff, 0.7);
backLight.position.set(0, 1, -2);
scene.add(backLight);

const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
scene.add(ambientLight);

// Load environment map for reflections
const textureLoader = new THREE.TextureLoader();
const envMap = textureLoader.load('path_to_your_environment_map.jpg'); // Replace with your image path

// Custom grid with thicker lines
function createGrid(size, divisions, color, thickness) {
    const gridHelper = new THREE.GridHelper(size, divisions, color, color);
    const gridGeometry = gridHelper.geometry;
    const material = new THREE.LineBasicMaterial({ color: color, linewidth: thickness });

    const lines = new THREE.LineSegments(gridGeometry, material);
    return lines;
}

// Add custom grid to the scene
const gridThickness = 20; // Set your desired thickness
const gridSize = 2000;
const gridDivisions = 20;
const gridColor = 0x3169E0; // Blue color for the grid
const customGrid = createGrid(gridSize, gridDivisions, gridColor, gridThickness);
scene.add(customGrid);

// Ground plane with specified color
const mesh = new THREE.Mesh(
    new THREE.PlaneGeometry(2000, 2000),
    new THREE.MeshPhongMaterial({ color: 0x0F2187 }) // Deep blue color for the ground
);
mesh.rotation.x = -Math.PI / 2;
mesh.receiveShadow = true;
scene.add(mesh);

// Grid Helper with specified color
const grid = new THREE.GridHelper(2000, 200, gridColor, gridColor); // Increased divisions to 100
grid.material.opacity = 0.2;
grid.material.transparent = true;
scene.add(grid);

// Overlay Grid for thicker lines (Optional)
const gridOverlay = new THREE.GridHelper(2000, 20, gridColor, gridColor);
gridOverlay.position.y = 0.1; // Slight offset
gridOverlay.material.opacity = 0.2;
gridOverlay.material.transparent = true;
scene.add(gridOverlay);


// Model paths
const models = ['model/sword1.gltf', 'model/sword2.gltf', 'model/sword3.gltf', 'model/sword4.gltf'];
let currentModelIndex = 0;

const loader = new GLTFLoader();
let currentModel, currentMixer;
const mixers = [];

function loadModel(modelPath) {
    loader.load(modelPath, function (gltf) {
        if (currentModel) {
            scene.remove(currentModel);
            if (currentMixer) {
                mixers.splice(mixers.indexOf(currentMixer), 1);
                currentMixer = null;
            }
        }
        currentModel = gltf.scene;
        currentModel.traverse(function (node) {
            if (node.isMesh) {
                node.castShadow = true;
            }
        });

        // Animation Mixer
        if (gltf.animations && gltf.animations.length) {
            currentMixer = new THREE.AnimationMixer(currentModel);
            mixers.push(currentMixer);

            gltf.animations.forEach((clip) => {
                const action = currentMixer.clipAction(clip);
                action.play();
            });
        }

        scene.add(currentModel);
    }, undefined, function (error) {
        console.error('An error happened:', error);
    });
}

loadModel(models[currentModelIndex]);




// OrbitControls with damping and drag speed detection
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.05;

let lastTime = performance.now();
let lastAngle = controls.getAzimuthalAngle();
const swapThreshold = 20; // Adjust the threshold based on testing
let canSwap = true; // Flag to control model swapping
let firstRotationDone = false; // Flag to check if first rotation is done

// Mouse down handler
function onMouseDown() {
    const speed = Math.abs(controls.getAzimuthalAngle() - lastAngle);
    if (firstRotationDone && speed > 0.001) {
        controls.dampingFactor = 0.2; // Increase damping to stop faster
    }
}

// Mouse up handler
function onMouseUp() {
    controls.dampingFactor = 0.05; // Reset damping after mouse up
    firstRotationDone = true; // First rotation completed
}

renderer.domElement.addEventListener('mousedown', onMouseDown);
renderer.domElement.addEventListener('mouseup', onMouseUp);

// Resize handler
window.addEventListener('resize', onWindowResize, false);
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);

    const time = performance.now();
    const delta = (time - lastTime) / 1000;
    lastTime = time;

    // Update mixers (animation)
    mixers.forEach((mixer) => {
        mixer.update(delta);
    });

    const angle = controls.getAzimuthalAngle();
    const speed = Math.abs(angle - lastAngle) / delta;

    if (speed > swapThreshold && canSwap) {
        currentModelIndex = (currentModelIndex + 1) % models.length;
        loadModel(models[currentModelIndex]);
        canSwap = false;
    }

    if (speed < 0.001) {
        canSwap = true;
    }

    lastAngle = angle;

    controls.update();
    renderer.render(scene, camera);
}

animate();